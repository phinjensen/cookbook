package Cookbook;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::Passphrase;
use Dancer::Plugin::ValidateTiny;
use utf8;

our $VERSION = '0.1';

#my schema = Schema->connect('dbi:Pg:dbname=jensen_cookbook', undef, undef, { pg_enable_utf8 => 1 });

#hook 'before' => sub {
#    if (! session('user') && request->path_info !~ m{^/login}) {
#        var requested_path => request->path_info;
#        request->path_info('/login');
#    }
#};

get '/register' => sub {
    if (session('user')) {
        template 'register', { error => 'You are already logged in!' };
    } else {
        template 'register';
    }
};

post '/register' => sub {
    my $params = params;
    my $data_valid = 0;

    # Validating params with rule file
    my $data = validator($params, 'register.pl');

    if ($data->{valid}) {
        my $new_user = schema->resultset('User')->create({
            name  => params->{user},
            email => params->{email},
            password => my $phrase = passphrase(params->{pass})->generate->rfc2307
        });
        $new_user->update;
        template 'register', { success => 1 };
    };
};
 
get '/login' => sub {
    # Display a login page; the original URL they requested is available as
    # vars->{requested_path}, so could be put in a hidden field in the form
    if (session('user')) {
        template 'login', { error => 'You are already logged in!' };
    } else {
        template 'login';
    }
};
 
post '/login' => sub {
    # Validate the username and password they supplied
    my $user = schema->resultset('User')->search({ name => params->{user} })->first;
    my $password = $user->password;
    if (passphrase(params->{pass})->matches($password)) {
        session user => params->{user};
        session logged_in => true;
        redirect params->{path} || '/';
    } else {
        redirect '/login?failed=1';
    }
};

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
