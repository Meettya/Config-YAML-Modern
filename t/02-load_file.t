#!perl -T

use Test::More tests => 9;
#use Test::More qw( no_plan );

# for filename resolution
use File::Basename qw/dirname/;
use File::Spec;

# for develop
#use lib qw(./lib/);
#use Smart::Comments;

BEGIN { use_ok('Config::YAML::Modern') };

my $class_name = 'Config::YAML::Modern';

my $config = new_ok( $class_name => [], $class_name );
# $config

ok ( ! eval{ $config->file_load() } && $@ , 'void call' );

ok ( ! eval{ $config->file_load('./this_file_cant_be_exists') } && $@ ,
		'non-existans file' );

# load file
note('try to load data from file');
my $config2 = new_ok( 
						$class_name => [ 'key_conversation' => 'ucfirst' , 
														# 'load_return_data' => 1
														]
						, $class_name );

my $data_dir = 'data';
my $file_name = 'file.one.yaml';

my @directories = File::Spec->splitdir(dirname(__FILE__));
push @directories, $data_dir;
my $path = File::Spec->catfile( @directories, $file_name );

my $return_object;
ok ( $return_object = $config2->file_load($path), 'load file' );

is_deeply( $config2, $return_object, 'return object matched' );

my $config3 = $class_name->new( 'key_conversation' => 'ucfirst' , 
														    'load_return_data' => 1 
														);

my $return_data = $config3->file_load($path);

is_deeply( $config2->config(), $return_data, 'return data matched' );

note ('try to load from file without suffix');

my $file_name2 = 'another.file';
my $path2 = File::Spec->catfile( @directories, $file_name2 );

my $config4 = $class_name->new( 'key_conversation' => 'ucfirst' , 
														    'i_dont_use_suffix' => 1 
														);

ok ( $config4->file_load($path2), 'load file without suffix' );