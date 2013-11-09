{
    fields => [qw/user email pass passconf/],
    checks => [
        [qw/user email pass passconf/] => is_required("Field required!"),
        
        user => is_long_at_most( 15, 'Username is too long' ),
        email => sub {
            my ( $value, $params ) = @_;
            Email::Valid->address($value) ? undef : 'Invalid email';
        },
        passconf => is_equal("pass", "Passwords don't match!"),
    ],
}
