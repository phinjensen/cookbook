package Cookbook;

use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);

use Cookbook::Account;

use utf8;

our $VERSION = '0.1';

get '/' => sub {
    my $recipes = schema->resultset('Recipe');
    my $render = template 'index', { query => $recipes };
    $recipes->reset();
    return $render;
};

get '/recipes/:id' => sub {
    my $recipe = schema->resultset('Recipe')->find(param('id'));
    template 'recipe', {
        recipe => $recipe,
        # Turn the ingredients and directions into an array so we can print them prettily with a FOREACH loop in the template
        map { $_ => [split(/[\r\n]+/, $recipe->$_)] } qw( ingredients directions ),
    };
};

get '/recipes/:id/edit' => sub {
    my $recipe = schema->resultset('Recipe')->find(param('id'));
    template 'edit';
};

get '/submit' => sub {
    template 'submit';
};

post '/submit' => sub {
    my $new_recipe = schema->resultset('Recipe')->create({
        map { $_ => params->{$_} } qw( name source ingredients directions )
    });
    $new_recipe->update;
    redirect '/recipes/'.$new_recipe->id;
};

true;
