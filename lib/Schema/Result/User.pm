package Schema::Result::User;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/ Ordered /);
__PACKAGE__->position_column('name');
__PACKAGE__->table('users');
__PACKAGE__->add_columns(
    id =>
        { data_type => 'integer',
          is_nullable => 0,
          is_auto_increment => 1,
        },
    name =>
        { data_type => 'varchar',
          size => 15,
          is_nullable => 0,
        },
    email =>
        { data_type => 'varchar',
          size => 100,
          is_nullable => 0,
        },
    password =>
        { data_type => 'varchar',
          size => 100,
          is_nullable => 0,
        }
);
__PACKAGE__->set_primary_key('id');

true;
