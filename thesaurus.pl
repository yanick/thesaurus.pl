#!/usr/bin/env perl

use 5.20.0;

package App::Thesaurus {

    use strict;

    use Template::Mustache;

use Moo;
use MooX::Options protect_argv => 0;
with 'Role::REST::Client';


use experimental qw/
    signatures
    postderef
/;

has '+server' => (
    default => 'https://od-api.oxforddictionaries.com',
);

has '+persistent_headers' => (
    default => sub {
        +{
            app_id => 'aeeea1e3',
            app_key => '112aeac451f2100fbf7be9cdff8a7ee1',
        }
    },
);

option synonym => (
    is => 'ro',
    default => 1,
);

option antonym => (
    is => 'ro',
    default => 0,
);

option lang => (
    is => 'ro',
    format => 's',
    default => 'en',
);

sub run($self) {
    use DDP;
    # die p $self->persistent_headers;
    $self->get_word($_) for @ARGV;
}

my $template = Template::Mustache->new( template => <<'END');
{{#results}}
# {{ word }}
{{#lexicalEntries}}
{{#entries}}
{{#senses}}
## sense
{{#examples}}
    > {{ text }}
{{/examples}}

### synonyms
{{#synonyms}}
* {{ text }}
{{/synonyms}}

### antonyms
{{#antonyms}}
* {{ text }}
{{/antonyms}}

{{/senses}}
{{/entries}}
{{/lexicalEntries}}
{{/results}}

END

sub get_word($self,$word) {
    my $r = $self->get( '/api/v1/entries/' . $self->lang . '/' . $word .'/synonyms' );

    say $template->render( $r->data );
}

}

App::Thesaurus->new_with_options->run;

