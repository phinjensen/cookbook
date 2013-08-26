package Schema::Result::Recipe;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/ Ordered /);
__PACKAGE__->position_column('name');
__PACKAGE__->table('recipe');
__PACKAGE__->add_columns(
    id =>
        { data_type => 'integer',
          is_nullable => 0,
          is_auto_increment => 1,
        },
    name =>
        { data_type => 'varchar',
          size => 100,
          is_nullable => 0,
        },
    source =>
        { data_type => 'varchar',
          size => 100,
          is_nullable => 1,
        },
    ingredients =>
        { data_type => 'text',
          is_nullable => 0,
        },
    directions =>
        { data_type => 'text',
          is_nullable => 0,
        }
);
__PACKAGE__->set_primary_key('id');

true;
