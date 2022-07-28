#!/usr/bin/perl

use strict;

sub getExecPath
{
    my $path = __FILE__;
    for (;;) {
        my $dir = `dirname $path`;
        chomp $dir;
        if (-e "$dir/HOTDOG/HOTDOG.h") {
            return $dir;
        }
        if (not -l $path) {
            last;
        }
        my $newpath = `readlink $path`;
        chomp $newpath;
        if (not $newpath) {
            last;
        }
        $path = $newpath;
    }
    print "Error: HOTDOG.h not found\n";
    exit(1);
}

my $execPath = getExecPath();
print "execPath: '$execPath'\n";

my $buildPath = "$execPath/Build";
print "buildPath: '$buildPath'\n";

my $objectsPath = "$buildPath/Objects";
my $logsPath = "$buildPath/Logs";

sub cflagsForFile
{
    my ($path) = @_;
    my $objcflags = '-std=c99 -fconstant-string-class=NSConstantString';
    if ($path =~ m/\/external\/tidy-html5-5.6.0\//) {
        return "-I$execPath/external/tidy-html5-5.6.0/include -I$execPath/external/tidy-html5-5.6.0/src";
    }
    if ($path eq "$execPath/misc/lib-htmltidy.m") {
        return "$objcflags -I$execPath/external/tidy-html5-5.6.0/include";
    }
    if ($path eq "$execPath/misc/misc-gmime.m") {
        my $flags = `pkg-config --cflags gmime-3.0`;
        return "$objcflags $flags";
    }
    if ($path eq "$execPath/misc/misc-chipmunk.m") {
        return "$objcflags -I$execPath/external/chipmunk/include";
    }
    if ($path =~ m/\.m$/) {
        return '-std=c99 -fconstant-string-class=NSConstantString';
    }
    return '';
}

sub ldflagsForFile
{
    my ($path) = @_;
    return '';
}

sub ldflagsForAllFiles
{
    my @files = @_;
    my @strs = map { ldflagsForFile($_) } @files;
    @strs = grep { $_ } @strs;
    return join ' ', @strs;
}




sub allSourceFiles
{
    my $cmd = <<EOF;
find -L
    $execPath/HOTDOG/linux/
	$execPath/HOTDOG/lib/
    $execPath/HOTDOG/objects/
    -not -name '*foundation-main*'
    -not -name '*linux-monitor*'
    -not -name '*linux-opengl*'
    -not -name '*linux-x11*'
    -not -name '*linux-dialog*'
    -not -name '*linux-execDir*'
    -not -name '*lib-process*'
    -not -name '*lib-file*'
    -not -name '*lib-date*'
    -not -name '*object-AmigaChecklist*'
    -not -name '*object-AmigaDir*'
    -not -name '*object-AmigaDrives*'
    -not -name '*object-AmigaNetworkInterfaces*'
    -not -name '*object-AmigaProgramBox*'
    -not -name '*object-AmigaRadio*'
    -not -name '*object-AmigaTextFields*'
    -not -name '*object-AquaChecklist*'
    -not -name '*object-AquaProgramBox*'
    -not -name '*object-AquaRadio*'
    -not -name '*object-AquaTextFields*'
    -not -name '*object-AtariSTDrives*'
    -not -name '*object-DesktopIcon*'
    -not -name '*object-ExposeMode*'
    -not -name '*object-HotDogStandNetworkInterfaces*'
    -not -name '*object-HotDogStandPrograms*'
    -not -name '*object-LockScreen*'
    -not -name '*object-MacChecklist*'
    -not -name '*object-MacClassicDir*'
    -not -name '*object-MacClassicDrives*'
    -not -name '*object-MacColorAudioDevices*'
    -not -name '*object-MacColorDir*'
    -not -name '*object-MacColorDrives*'
    -not -name '*object-MacProgramBox*'
    -not -name '*object-MacRadio*'
    -not -name '*object-MacTextFields*'
    -not -name '*object-MailInterface*'
    -not -name '*object-MailMessage*'
    -not -name '*object-Progress*'
    -not -name '*object-Stopwatch*'
    -not -name '*object-TouchPuckDemo*'
    -not -name '*object-TouchRubberBandDemo*'
    -not -name '*object-TouchTrackingDemo*'
    -not -name '*object-VolumeMenu*'
    -not -name '*object-KaboomClone*'
    -not -name '*misc-worldClock*'
EOF
    $cmd =~ s/\n/ /g;
    my @lines = `$cmd`;
    @lines = grep /\.(c|m|mm|cpp)$/, @lines;
    chomp(@lines);
    return @lines;
}

sub compileSourcePath
{
    my ($sourcePath) = @_;

    my $objectPath = objectPathForPath($sourcePath);
    my $logPath = logPathForPath($sourcePath);

    my $cflags = cflagsForFile($sourcePath);

#    -Werror=objc-method-access
#clang -c -O0 -g -pg
	my $cmd = <<EOF;
$execPath/Toolchain/bin/i586-elf-gcc -c -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Wno-unused-parameter -Wno-incompatible-pointer-types
    -Werror=implicit-function-declaration
    -Werror=return-type
    -I$execPath/HOTDOG
    -I$execPath/HOTDOG/linux
    -I$execPath/HOTDOG/lib
    -I$execPath/HOTDOG/objects
    -I$execPath/HOTDOG/include
    -I$execPath/Kernel
    -I$execPath/Kernel/include
    -I$execPath/ObjectiveC/libobjc
    $cflags
    -DBUILD_FOR_MEDMOS
    -DBUILD_FOUNDATION
    -DBUILD_WITH_BGRA_PIXEL_FORMAT
    -o $objectPath $sourcePath 2>>$logPath
EOF

    writeTextToFile("${cmd}\n---CUT HERE---\n", $logPath);

    $cmd =~ s/\n/ /g;
	system($cmd);
}

sub linkSourcePaths
{
    my @arr = @_;
    my $ldflags = ldflagsForAllFiles(@arr);
    @arr = map { objectPathForPath($_) } @arr;
    my $objectFiles = join ' ', @arr;
#    -pg
    my $cmd = <<EOF;
$execPath/Toolchain/bin/i586-elf-gcc -T $execPath/Kernel/linker.ld -o $execPath/ISO/medmos -ffreestanding -O2 -nostdlib
    $execPath/Kernel/Objects/crti.o
    $execPath/Toolchain/lib/gcc/i586-elf/11.3.0/crtbegin.o
    $execPath/Kernel/Objects/boot.o
    $execPath/Kernel/Objects/kernel.o
    $execPath/ObjectiveC/Objects/init.o
    $execPath/ObjectiveC/Objects/hash.o
    $execPath/ObjectiveC/Objects/selector.o
    $execPath/ObjectiveC/Objects/protocols.o
    $execPath/ObjectiveC/Objects/class.o
    $execPath/ObjectiveC/Objects/error.o
    $execPath/ObjectiveC/Objects/memory.o
    $execPath/ObjectiveC/Objects/sendmsg.o
    $execPath/ObjectiveC/Objects/accessors.o
    $execPath/ObjectiveC/Objects/linking.o
    $execPath/ObjectiveC/Objects/encoding.o
    $execPath/ObjectiveC/Objects/sarray.o
    $execPath/ObjectiveC/Objects/nil_method.o
    $execPath/ObjectiveC/Objects/methods.o
    $execPath/ObjectiveC/Objects/Object.o
    $execPath/ObjectiveC/Objects/gc.o
    $execPath/ObjectiveC/Objects/ivars.o
    $execPath/ObjectiveC/Objects/objects.o
    $execPath/ObjectiveC/Objects/objc-foreach.o
    $objectFiles
    $execPath/Toolchain/lib/gcc/i586-elf/11.3.0/crtend.o
    $execPath/Kernel/Objects/crtn.o
    -lgcc -ObjC
EOF
#    $objectFiles
if (0) {
    print <<EOF;
    Build/Objects/foundation-.o
    Build/Objects/foundation-printf.o
    Build/Objects/foundation-qsort_r.o
    Build/Objects/lib-Definitions.o
    Build/Objects/lib-NSString.o
    Build/Objects/graphics-ataristfont.o
    Build/Objects/graphics-chicagofont.o
    Build/Objects/graphics-c64font.o
    Build/Objects/graphics-cards.o
    Build/Objects/graphics-chat.o
    Build/Objects/graphics-finalfantasy6font.o
    Build/Objects/graphics-genevafont.o
    Build/Objects/graphics-monacofont.o
    Build/Objects/graphics-topazfont.o
    Build/Objects/graphics-winsystemfont.o
EOF
}
    writeTextToFile($cmd, "$logsPath/LINK");
    $cmd =~ s/\n/ /g;
    system($cmd);
}

##########


sub writeTextToFile
{
    my ($text, $path) = @_;

    local *FH;
    open FH, ">$path";
    print FH $text;
    close FH;
}

sub makeDirectory
{
    my ($path) = @_;
    if (-e $path) {
        if (-d $path) {
            return;
        }
        die("already exists but is not a directory: '$path'");
    }
    mkdir $path, 0755 or die("unable to make directory '$path'");
}

sub nameForPath
{
    my ($path) = @_;
    my @comps = split '/', $path;
    my $str = $comps[-1];
    my @arr = split '\.', $str;
    return $arr[0];
}

sub modificationDateForPath
{
    my ($path) = @_;
    return (stat ($path))[9];
}

sub objectPathForPath
{
    my ($sourcePath) = @_;
    my $name = nameForPath($sourcePath);
    my $objectPath = $objectsPath . "/" . $name . ".o";
    return $objectPath;
}
 
sub logPathForPath
{
    my ($sourcePath) = @_;
    my $name = nameForPath($sourcePath);
    my $logPath = $logsPath . "/" . $name . ".log";
    return $logPath;
}
sub statusForPath
{
    my ($sourcePath) = @_;
    my $objectPath = objectPathForPath($sourcePath);
    my $logPath = logPathForPath($sourcePath);
    my $dateForSource = modificationDateForPath($sourcePath);
    my $dateForObject = modificationDateForPath($objectPath);
    my $dateForLog = modificationDateForPath($logPath);
    if (not -e $sourcePath) {
        return "*sourceDoesNotExist";
    }
    if (-e $objectPath) {
        if ($dateForSource > $dateForObject) {
            # needToCompile
        } else {
            return "ok";
        }
    } else {
        # needToCompile
    }
    if (not -e $logPath) {
        return "*needToCompile";
    }
    if ($dateForSource > $dateForLog) {
        return "*needToCompile";
    }
    return "*compileError";
}


makeDirectory($buildPath);
makeDirectory($objectsPath);
makeDirectory($logsPath);

my @lines = allSourceFiles();
foreach my $line (@lines) {
    my $status = statusForPath($line);
    if ($status eq 'ok') {
        next;
    }

    print "Compiling " . nameForPath($line) . "\n";
    compileSourcePath($line);
    $status = statusForPath($line);


    if ($status eq 'ok') {
        print nameForPath($line) . ": " . "$status\n";
        next;
    }
    my $logPath = logPathForPath($line);
    print `cat $logPath`;
    print nameForPath($line) . ": $status\n";
    exit(0);
}

print "Linking\n";
linkSourcePaths(@lines);

