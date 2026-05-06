use File::Path qw(make_path);
use File::Spec;
use Time::HiRes qw(time);

my $compile_start_time = time;

END {
    printf "[latexmk] elapsed time: %.3f [sec]\n", time - $compile_start_time;
    print "[latexmk] output pdf: $pdf_path\n";
}

$pdf_mode = 3;
$aux_dir = 'build';
$out_dir = '.';
$emulate_aux = 1;
$latex = 'internal fmtlatex uplatex %Z %Y %A %S %R -synctex=1 -file-line-error -halt-on-error %O';
$dvipdf = 'dvipdfmx %O -o %D %S';
$max_repeat = 5;
$clean_ext = "$clean_ext dvi synctex.gz";

my $pwd=`pwd`;
chomp $pwd;
my $comdir="$pwd/$aux_dir";
my $comname=".latexmk";

make_path($aux_dir) unless -d $aux_dir;

{
    $clean_ext="$clean_ext fmt";
    my $initial = 1;

    sub fmtlatex {
        my ($engine, $outpath, $auxpath, $basename, $texname, $jobname, @args) = @_;
        my $options = join(' ', @args);

        if ($initial == 1){
            $initial = 0;
            my $flag = 0;
            print "fmtlatex: checking if the preamble changed...\n";
            if (&check_preamble_change($auxpath,$jobname,$texname) == 0){
                print "fmtlatex: the preamble is not changed.\n";
                print "fmtlatex: checking if the common fmt file is owned...\n";
                if (&check_com_owned("$pwd/$texname") == 0){
                    print "fmtlatex: the common fmt file is not owned.\n";
                    $flag = 1;
                }else{
                    print "fmtlatex: the common fmt file is owned.\n";
                }
            }else{
                print "fmtlatex: the preamble is changed.\n";
                $flag = 1;
            }
            if ($flag == 1){
                print "rewriting the common fmt file in ini mode...\n";
                my $iniret=Run_subst("$engine -ini $options -output-directory=\"$comdir\" -jobname=\"$comname\" \\\&$engine mylatexformat.ltx $texname");
                if($iniret == 0){
                    print "fmtlatex: the common fmt file rewrited. saving preamble...\n";
                    &memorize_preamble_change($auxpath,$jobname);
                    &hold_com("$pwd/$texname");
                }else{
                    print "fmtlatex: failed to rewrite the common fmt file.\n";
                    &forget_preamble_change($auxpath,$jobname);
                    &throw_com("$pwd/$texname");
                    return $iniret;
                }
            }else{
                print "keep the common fmt file.\n";
                &forget_preamble_change($auxpath,$jobname);
            }
        }
        print "fmtlatex: the common fmt file is ready, so running normal latex... \n";
        my $finalres = Run_subst("$engine -fmt \"$comdir/$comname\" $options $texname");
        return $finalres;
    }
}

{
    sub check_com_owned(){
        my $path=$_[0];
        open(my $fh, "<", "$comdir/$comname.info") or return 0;
        my $holder=<$fh>;
        close($fh);
        if($path eq $holder){
            return 1;
        }else{
            return 0;
        }
    }
    sub hold_com(){
        my $path=$_[0];
        open(my $fh, ">", "$comdir/$comname.info");
        print $fh "$path";
        close($fh);
    }
    sub throw_com(){
        open(my $fh, ">", "$comdir/$comname.info");
        print $fh "";
        close($fh);
    }
}

{
    my $prea_ext = "prea";
    $clean_ext="$clean_ext $prea_ext";

    my $gethead = "awk '!/%.*/{if (p) print}BEGIN{p=1}/\\\\endofdump/{p=0}/\\\\begin\\{document\\}/{p=0}'";
    my $comphead = "sed -e 's/ *\$//g' -e 's/%.*\$//g'";

    sub check_preamble_change{
        my ($auxpath, $basename, $texname) = @_;
        my $preapath="$auxpath$basename.$prea_ext";
        system("echo \"\" > \"$preapath.tmp\"");

        my $chain_flag=1;
        do{
            system("$gethead \"$texname\"|$comphead >> \"$preapath.tmp\"");
            system("echo \"\" >> \"$preapath.tmp\"");

            my $mastername = `head -n 1 "$texname"`;
            if ($mastername =~ /^ *\\documentclass\[.*\]\{subfiles\} *$/){
                $mastername =~ s/^ *\\documentclass\[//g;
                $mastername =~ s/\]\{subfiles\} *$//g;
            }else{
                $mastername = "";
            }
            chomp($mastername);
            if ($mastername ne ""){
                $texname = "$mastername.tex";
            }else{
                $chain_flag=0;
            }
        }while($chain_flag == 1);

        &process_input_files($preapath);

        sub process_input_files{
            my ($preapath) = @_;
            my $loading_limit=1000;
            open(my $fh, '<', $preapath.".tmp") or die "Error: $!\n";
            print "Processing $preapath.tmp\n";
            my $i=0;
            while (my $line = <$fh>) {
                $i=$i+1;
                last if $i >= $loading_limit;
                if ($line =~ /\\input\{([^}]*)\}/) {
                    my $inputname = $1;
                    $inputname =~ s/\} *$//g;
                    print "Found input directive: $inputname\n";
                    system("$gethead \"$inputname\"|$comphead >> \"$preapath.tmp\"");
                    system("echo \"\" >> \"$preapath.tmp\"");
                }
            }
        }

        my $checkret = system("diff -Bb \"$preapath.tmp\" \"$preapath\"");
        return $checkret;
    }
    sub forget_preamble_change{
        my ($auxpath, $basename) = @_;
        system("rm \"$auxpath$basename.$prea_ext.tmp\"");
    }
    sub memorize_preamble_change{
        my ($auxpath, $basename) = @_;
        system("mv \"$auxpath$basename.$prea_ext.tmp\" \"$auxpath$basename.$prea_ext\"");
    }
}
