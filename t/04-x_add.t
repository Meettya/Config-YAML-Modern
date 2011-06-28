#!perl -T

use Test::More tests => 13;
#use Test::More qw( no_plan );

# for filename resolution
use File::Basename qw/dirname/;
use File::Spec;

# for develop
#use lib qw(./lib/);
#use Smart::Comments;

BEGIN { use_ok('Config::YAML::Modern') };

my $class_name = 'Config::YAML::Modern';

my $args = [
 			'key_conversion' => 'ucfirst',
 			'i_dont_use_suffix' => 1
				];

my $config1 = new_ok( $class_name => $args, $class_name );

my $config2 = new_ok( $class_name => $args, $class_name);

my $config_check = new_ok( $class_name => $args, $class_name );

my $config_for_empty = new_ok( $class_name => $args, $class_name );
										 
my $data_dir = 'data';
my $data_sub_dir = 'subdata';

my @directories = File::Spec->splitdir(dirname(__FILE__));
push @directories, $data_dir;
my $path_dir = File::Spec->catdir( @directories );

my $filename1 = 'another.file';
my $path_file1 = File::Spec->catfile( @directories, $filename1 );
$config1->file_load($path_file1);

my $filename2 = 'another.file.one';
my $path_file2 = File::Spec->catfile( @directories, $filename2 );
$config2->file_load($path_file2);

my $filename_check = 'check.file';
my $path_file_check = File::Spec->catfile( @directories, $filename_check );

$config_check->file_load($path_file_check);

# check hash_add
note('merge data by hash_add');
ok ( ! eval { $config1->hash_add() } && $@ , 'empty hash_add depricated');
ok ( ! eval { $config1->hash_add(['one', 'two']) } && $@ , 'not hash at hash_add depricated');


$config1->hash_add($config2->config());

is_deeply( $config1->dive(qw/Another/),
					 $config_check->dive(qw/Check/), 
					 'object merged by hash_add properly' );

#re-use object and check file_add	 
note('merge data by file_add');
# make more fun
$config1->file_load($path_file2)->file_add($path_file1, 'RIGHT_PRECEDENT' );

is_deeply( $config1->dive(qw/Another/),
					 $config_check->dive(qw/Check/), 
					 'object merged by file_add properly' );

#re-use object and check dir_add	 
note('merge data by dir_add');

push @directories, $data_sub_dir;
$path_dir = File::Spec->catdir( @directories );

$config1->file_load($path_file2)->dir_add($path_dir, 'RIGHT_PRECEDENT');

is_deeply( $config1->dive(qw/Another/),
					 $config_check->dive(qw/Check/), 
					 'object merged by dir_add properly' );
					 
note('check empty root hash correct addition');

my $fulled_hash = { c => 4, d => 5 };
my $empty_hash	= {};

$config_for_empty->hash_add($empty_hash);

is_deeply( $config_for_empty->config(),
					 $empty_hash, 
					 'empty object & empty hash merged properly' );

$config_for_empty->hash_add($fulled_hash);

is_deeply( $config_for_empty->config(),
					 $fulled_hash, 
					 'empty object & fulled hash merged properly' );
					 
$config_for_empty->hash_add($empty_hash);

is_deeply( $config_for_empty->config(),
					 $fulled_hash, 
					 'fulled object & empty hash merged properly' );
