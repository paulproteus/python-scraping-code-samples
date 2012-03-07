# Copyright 2006 ThoughtWorks, Inc
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#


package WWW::Selenium;
use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Request;
use URI::Escape;
use Carp qw(croak);
use Time::HiRes qw(sleep);

use strict;
use warnings;

our $VERSION = '0.93';

=head1 NAME

WWW::Selenium - Perl Client for the Selenium Remote Control test tool

=head1 SYNOPSIS

    use WWW::Selenium;
    
    my $sel = WWW::Selenium->new( host => "localhost", 
                                  port => 4444, 
                                  browser => "*iexplore", 
                                  browser_url => "http://www.google.com",
                                );
    
    $sel->start;
    $sel->open("http://www.google.com");
    $sel->type("q", "hello world");
    $sel->click("btnG");
    $sel->wait_for_page_to_load(5000);
    print $sel->get_title;
    $sel->stop;

=head1 DESCRIPTION

Selenium Remote Control (SRC) is a test tool that allows you to write
automated web application UI tests in any programming language against
any HTTP website using any mainstream JavaScript-enabled browser.  SRC
provides a Selenium Server, which can automatically start/stop/control
any supported browser. It works by using Selenium Core, a pure-HTML+JS
library that performs automated tasks in JavaScript; the Selenium
Server communicates directly with the browser using AJAX
(XmlHttpRequest).

L<http://www.openqa.org/selenium-rc/>

This module sends commands directly to the Server using simple HTTP
GET/POST requests.  Using this module together with the Selenium
Server, you can automatically control any supported browser.

To use this module, you need to have already downloaded and started
the Selenium Server.  (The Selenium Server is a Java application.)

=cut

### This next part is auto-generated based on the big comment in selenium-api.js

#Defines an object that runs Selenium commands.

=head3 Element Locators

Element Locators tell Selenium which HTML element a command refers to.The format of a locator is:

=over

I<locatorType>B<=>I<argument>

=back

We support the following strategies for locating elements:

=over

=item *

B<identifier>=I<id>: Select the element with the specified @id attribute. If no match isfound, select the first element whose @name attribute is I<id>.(This is normally the default; see below.)

=item *

B<id>=I<id>:Select the element with the specified @id attribute.

=item *

B<name>=I<name>:Select the first element with the specified @name attribute.

=over

=item *

username

=item *

name=username

=back

The name may optionally be followed by one or more I<element-filters>, separated from the name by whitespace.  If the I<filterType> is not specified, B<value> is assumed.

=over

=item *

name=flavour value=chocolate

=back

=item *

B<dom>=I<javascriptExpression>: Find an element by evaluating the specified string.  This allows you to traverse the HTML Document ObjectModel using JavaScript.  Note that you must not return a value in this string; simply make it the last expression in the block.

=over

=item *

dom=document.forms['myForm'].myDropdown

=item *

dom=document.images[56]

=item *

dom=function foo() { return document.links[1]; }; foo();

=back

=item *

B<xpath>=I<xpathExpression>: Locate an element using an XPath expression.

=over

=item *

xpath=//img[@alt='The image alt text']

=item *

xpath=//table[@id='table1']//tr[4]/td[2]

=item *

xpath=//a[contains(@href,'#id1')]

=item *

xpath=//a[contains(@href,'#id1')]/@class

=item *

xpath=(//table[@class='stylee'])//th[text()='theHeaderText']/../td

=item *

xpath=//input[@name='name2' and @value='yes']

=item *

xpath=//*[text()="right"]

=back

=item *

B<link>=I<textPattern>:Select the link (anchor) element which contains text matching thespecified I<pattern>.

=over

=item *

link=The link text

=back

=item *

B<css>=I<cssSelectorSyntax>:Select the element using css selectors. Please refer to http://www.w3.org/TR/REC-CSS2/selector.html (CSS2 selectors), http://www.w3.org/TR/2001/CR-css3-selectors-20011113/ (CSS3 selectors) for more information. You can also check the TestCssLocators test in the selenium test suite for an example of usage, which is included in the downloaded selenium core package.

=over

=item *

css=a[href="#id3"]

=item *

css=span#firstChild + span

=back

Currently the css selector locator supports all css1, css2 and css3 selectors except namespace in css3, some pseudo classes(:nth-of-type, :nth-last-of-type, :first-of-type, :last-of-type, :only-of-type, :visited, :hover, :active, :focus, :indeterminate) and pseudo elements(::first-line, ::first-letter, ::selection, ::before, ::after). 

=item *

B<ui>=I<uiSpecifierString>:Locate an element by resolving the UI specifier string to another locator, and evaluating it. See the http://svn.openqa.org/fisheye/browse/~raw,r=trunk/selenium/trunk/src/main/resources/core/scripts/ui-doc.html (Selenium UI-Element Reference) for more details.

=over

=item *

ui=loginPages::loginButton()

=item *

ui=settingsPages::toggle(label=Hide Email)

=item *

ui=forumPages::postBody(index=2)//a[2]

=back

=back

Without an explicit locator prefix, Selenium uses the following defaultstrategies:

=over

=item *

B<dom>, for locators starting with "document."

=item *

B<xpath>, for locators starting with "//"

=item *

B<identifier>, otherwise

=back

=head3 Element Filters

Element filters can be used with a locator to refine a list of candidate elements.  They are currently used only in the 'name' element-locator.

Filters look much like locators, ie.

=over

I<filterType>B<=>I<argument>

=back

Supported element-filters are:

B<value=>I<valuePattern>

=over

Matches elements based on their values.  This is particularly useful for refining a list of similarly-named toggle-buttons.

=back

B<index=>I<index>

=over

Selects a single element based on its position in the list (offset from zero).

=back

=head3 String-match Patterns

Various Pattern syntaxes are available for matching string values:

=over

=item *

B<glob:>I<pattern>:Match a string against a "glob" (aka "wildmat") pattern. "Glob" is akind of limited regular-expression syntax typically used in command-lineshells. In a glob pattern, "*" represents any sequence of characters, and "?"represents any single character. Glob patterns match against the entirestring.

=item *

B<regexp:>I<regexp>:Match a string using a regular-expression. The full power of JavaScriptregular-expressions is available.

=item *

B<regexpi:>I<regexpi>:Match a string using a case-insensitive regular-expression.

=item *

B<exact:>I<string>:Match a string exactly, verbatim, without any of that fancy wildcardstuff.

=back

If no pattern prefix is specified, Selenium assumes that it's a "glob"pattern.

For commands that return multiple values (such as verifySelectOptions),the string being matched is a comma-separated list of the return values,where both commas and backslashes in the values are backslash-escaped.When providing a pattern, the optional matching syntax (i.e. glob,regexp, etc.) is specified once, as usual, at the beginning of thepattern.

=cut

eval 'require Encode';
my $encode_present = !$@;
Encode->import('decode_utf8') if $encode_present;

=head2 METHODS

The following methods are available:

=over

=item $sel = WWW::Selenium-E<gt>new( %args )

Constructs a new C<WWW::Selenium> object, specifying a Selenium Server
host/port, a command to launch the browser, and a starting URL for the
browser.

Options:

=over

=item * C<host>

host is the host name on which the Selenium Server resides.

=item * C<port>

port is the port on which the Selenium Server is listening.

=item * C<browser_url>

browser_url is the starting URL including just a domain name.  We'll
start the browser pointing at the Selenium resources on this URL,
e.g. "http://www.google.com" would send the browser to
"http://www.google.com/selenium-server/SeleneseRunner.html"

=item * C<browser> or C<browser_start_command>

This is the command string used to launch the browser, e.g.
"*firefox", "*iexplore" or "/usr/bin/firefox"

This option may be any one of the following:

=over

=item * C<*firefox [absolute path]>

Automatically launch a new Firefox process using a custom Firefox
profile.
This profile will be automatically configured to use the Selenium
Server as a proxy and to have all annoying prompts
("save your password?" "forms are insecure" "make Firefox your default
browser?" disabled.  You may optionally specify
an absolute path to your firefox executable, or just say "*firefox". 
If no absolute path is specified, we'll look for
firefox.exe in a default location (normally c:\program files\mozilla
firefox\firefox.exe), which you can override by
setting the Java system property C<firefoxDefaultPath> to the correct
path to Firefox.

=item * C<*iexplore [absolute path]>

Automatically launch a new Internet Explorer process using custom
Windows registry settings.
This process will be automatically configured to use the Selenium
Server as a proxy and to have all annoying prompts
("save your password?" "forms are insecure" "make Firefox your default
browser?" disabled.  You may optionally specify
an absolute path to your iexplore executable, or just say "*iexplore". 
If no absolute path is specified, we'll look for
iexplore.exe in a default location (normally c:\program files\internet
explorer\iexplore.exe), which you can override by
setting the Java system property C<iexploreDefaultPath> to the correct
path to Internet Explorer.

=item * C</path/to/my/browser [other arguments]>

You may also simply specify the absolute path to your browser
executable, or use a relative path to your executable (which we'll try
to find on your path).  B<Warning:> If you
specify your own custom browser, it's up to you to configure it
correctly.  At a minimum, you'll need to configure your
browser to use the Selenium Server as a proxy, and disable all
browser-specific prompting.

=back

=item * C<auto_stop>

Defaults to true, and will attempt to close the browser if the object
goes out of scope and stop hasn't been called.

=item * C<session_id>

Optional argument that can be used to reuse session_ids between test
runs.  This can make for faster testing.

=back

=cut

sub new {
    my ($class, %args) = @_;
    my $self = {    # default args:
        host                  => 'localhost',
        port                  => 4444,
        auto_stop             => 1,
        browser_start_command => delete $args{browser} || '*firefox',
        extension_js          => "",
        session_id            => undef,
        %args,
    };
    croak 'browser_url is mandatory!' unless $self->{browser_url};
    bless $self, $class or die "Can't bless $class: $!";
    return $self;
}

sub set_extension_js {
    my $self = shift;
    $self->{extension_js} = shift;
}

sub start {
    my $self = shift;
    return if $self->{session_id};
    $self->{session_id} = $self->get_string("getNewBrowserSession", 
                                            $self->{browser_start_command}, 
                                            $self->{browser_url},
                                            $self->{extension_js});
}

sub stop {
    my $self = shift;
    return unless defined $self->{session_id};
    $self->do_command("testComplete");
    $self->{session_id} = undef;
}

sub do_command {
    my ($self, $command, @args) = @_;

    $self->{_page_opened} = 1 if $command eq 'open';

    # Check that user has called open()
    my %valid_pre_open_commands = (
        testComplete => 1,
        getNewBrowserSession => 1,
        setTimeout => 1,
    );
    if (!$self->{_page_opened} and !$valid_pre_open_commands{$command}) {
        die "You must open a page before calling $command. eg: \$sel->open('/');\n";
    }

    $command = uri_escape($command);
    my $fullurl = "http://$self->{host}:$self->{port}/selenium-server/driver/";
    my $content = "cmd=$command";
    my $i = 1;
    @args = grep defined, @args;
    while (@args) {
        $content .= "&$i=" . URI::Escape::uri_escape_utf8(shift @args);
        $i++;
    }
    if (defined $self->{session_id}) {
        $content .= "&sessionId=$self->{session_id}";
    }
    print "---> Requesting $fullurl\n" if $self->{verbose};

    # We use the full version of LWP to make sure we issue an 
    # HTTP 1.1 request (SRC-25)
    my $ua = LWP::UserAgent->new;
    my $header = HTTP::Headers->new( Content_Type => 'application/x-www-form-urlencoded; charset=utf-8' );
    my $response = $ua->request( HTTP::Request->new( 'POST', $fullurl, $header, $content ) );
    my $result;
    if ($response->is_success) {
        $result = $response->content;
        print "Got result: $result\n" if $self->{verbose};
    }
    else {
        die "Error requesting $fullurl:\n" . $response->status_line . "\n";
    }
    $result = decode_utf8($result) if $encode_present;
    die "Error requesting $fullurl:\n$result\n" unless $result =~ /^OK/;
    return $result;
}

sub get_string {
    my $self = shift;
    my $result = $self->do_command(@_);
    return substr($result, 3);
}

sub get_string_array {
    my $self = shift;
    my $result = $self->get_string(@_);
    my $token = "";
    my @tokens = ();
    my @chars = split(//, $result);
    for (my $i = 0; $i < @chars; $i++) {
        my $char = $chars[$i];
        if ($char eq '\\') {
            $i++;
            $char = $chars[$i];
            $token .= $char;
        } elsif ($char eq ',') {
            push (@tokens, $token);
            $token = "";
        } else {
            $token .= $char;
        }
    }
    push (@tokens, $token);
    return @tokens;
}

sub get_number {
    my $self = shift;
    my $result = $self->get_string(@_);
    # Is there something else I need to do here?
    return $result;
}

sub get_number_array {
    my $self = shift;
    my @result = $self->get_string_array(@_);
    # Is there something else I need to do here?
    return @result;
}

sub get_boolean {
    my $self = shift;
    my $result = $self->get_string(@_);
    if ($result eq "true") {
        return 1;
    }
    if ($result eq "false") {
        return 0;
    }
    die "result is neither 'true' nor 'false': $result";
}

sub get_boolean_array {
    my $self = shift;
    my @result = $self->get_string_array(@_);
    my @boolarr = ();
    for (my $i = 0; $i < @result; $i++) {
        if ($result[$i] eq "true") {
            push (@boolarr, 1);
            next;
        }
        if ($result[$i] eq "false") {
            push (@boolarr, 0);
            next;
        }
        die "result is neither 'true' nor 'false': ". $result[$i];
    }
    return @boolarr;
}

=item $sel-E<gt>pause($timeout)

Waits $timeout milliseconds (default: 1 second)

=cut

sub pause {
    my ($self,$timeout) = @_;
    $timeout = 1000  unless defined $timeout;
    $timeout /= 1000;
    sleep $timeout;
}

### From here on, everything's auto-generated from XML

=item $sel-E<gt>click($locator)

Clicks on a link, button, checkbox or radio button. If the click actioncauses a new page to load (like a link usually does), callwaitForPageToLoad.

=over

$locator is an element locator

=back

=cut

sub click {
    my $self = shift;
    $self->do_command("click", @_);
}

=item $sel-E<gt>double_click($locator)

Double clicks on a link, button, checkbox or radio button. If the double click actioncauses a new page to load (like a link usually does), callwaitForPageToLoad.

=over

$locator is an element locator

=back

=cut

sub double_click {
    my $self = shift;
    $self->do_command("doubleClick", @_);
}

=item $sel-E<gt>context_menu($locator)

Simulates opening the context menu for the specified element (as might happen if the user "right-clicked" on the element).

=over

$locator is an element locator

=back

=cut

sub context_menu {
    my $self = shift;
    $self->do_command("contextMenu", @_);
}

=item $sel-E<gt>click_at($locator, $coord_string)

Clicks on a link, button, checkbox or radio button. If the click actioncauses a new page to load (like a link usually does), callwaitForPageToLoad.

=over

$locator is an element locator

$coord_string is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.

=back

=cut

sub click_at {
    my $self = shift;
    $self->do_command("clickAt", @_);
}

=item $sel-E<gt>double_click_at($locator, $coord_string)

Doubleclicks on a link, button, checkbox or radio button. If the actioncauses a new page to load (like a link usually does), callwaitForPageToLoad.

=over

$locator is an element locator

$coord_string is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.

=back

=cut

sub double_click_at {
    my $self = shift;
    $self->do_command("doubleClickAt", @_);
}

=item $sel-E<gt>context_menu_at($locator, $coord_string)

Simulates opening the context menu for the specified element (as might happen if the user "right-clicked" on the element).

=over

$locator is an element locator

$coord_string is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.

=back

=cut

sub context_menu_at {
    my $self = shift;
    $self->do_command("contextMenuAt", @_);
}

=item $sel-E<gt>fire_event($locator, $event_name)

Explicitly simulate an event, to trigger the corresponding "onI<event>"handler.

=over

$locator is an element locator

$event_name is the event name, e.g. "focus" or "blur"

=back

=cut

sub fire_event {
    my $self = shift;
    $self->do_command("fireEvent", @_);
}

=item $sel-E<gt>focus($locator)

Move the focus to the specified element; for example, if the element is an input field, move the cursor to that field.

=over

$locator is an element locator

=back

=cut

sub focus {
    my $self = shift;
    $self->do_command("focus", @_);
}

=item $sel-E<gt>key_press($locator, $key_sequence)

Simulates a user pressing and releasing a key.

=over

$locator is an element locator

$key_sequence is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".

=back

=cut

sub key_press {
    my $self = shift;
    $self->do_command("keyPress", @_);
}

=item $sel-E<gt>shift_key_down()

Press the shift key and hold it down until doShiftUp() is called or a new page is loaded.

=cut

sub shift_key_down {
    my $self = shift;
    $self->do_command("shiftKeyDown", @_);
}

=item $sel-E<gt>shift_key_up()

Release the shift key.

=cut

sub shift_key_up {
    my $self = shift;
    $self->do_command("shiftKeyUp", @_);
}

=item $sel-E<gt>meta_key_down()

Press the meta key and hold it down until doMetaUp() is called or a new page is loaded.

=cut

sub meta_key_down {
    my $self = shift;
    $self->do_command("metaKeyDown", @_);
}

=item $sel-E<gt>meta_key_up()

Release the meta key.

=cut

sub meta_key_up {
    my $self = shift;
    $self->do_command("metaKeyUp", @_);
}

=item $sel-E<gt>alt_key_down()

Press the alt key and hold it down until doAltUp() is called or a new page is loaded.

=cut

sub alt_key_down {
    my $self = shift;
    $self->do_command("altKeyDown", @_);
}

=item $sel-E<gt>alt_key_up()

Release the alt key.

=cut

sub alt_key_up {
    my $self = shift;
    $self->do_command("altKeyUp", @_);
}

=item $sel-E<gt>control_key_down()

Press the control key and hold it down until doControlUp() is called or a new page is loaded.

=cut

sub control_key_down {
    my $self = shift;
    $self->do_command("controlKeyDown", @_);
}

=item $sel-E<gt>control_key_up()

Release the control key.

=cut

sub control_key_up {
    my $self = shift;
    $self->do_command("controlKeyUp", @_);
}

=item $sel-E<gt>key_down($locator, $key_sequence)

Simulates a user pressing a key (without releasing it yet).

=over

$locator is an element locator

$key_sequence is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".

=back

=cut

sub key_down {
    my $self = shift;
    $self->do_command("keyDown", @_);
}

=item $sel-E<gt>key_up($locator, $key_sequence)

Simulates a user releasing a key.

=over

$locator is an element locator

$key_sequence is Either be a string("\" followed by the numeric keycode  of the key to be pressed, normally the ASCII value of that key), or a single  character. For example: "w", "\119".

=back

=cut

sub key_up {
    my $self = shift;
    $self->do_command("keyUp", @_);
}

=item $sel-E<gt>mouse_over($locator)

Simulates a user hovering a mouse over the specified element.

=over

$locator is an element locator

=back

=cut

sub mouse_over {
    my $self = shift;
    $self->do_command("mouseOver", @_);
}

=item $sel-E<gt>mouse_out($locator)

Simulates a user moving the mouse pointer away from the specified element.

=over

$locator is an element locator

=back

=cut

sub mouse_out {
    my $self = shift;
    $self->do_command("mouseOut", @_);
}

=item $sel-E<gt>mouse_down($locator)

Simulates a user pressing the left mouse button (without releasing it yet) onthe specified element.

=over

$locator is an element locator

=back

=cut

sub mouse_down {
    my $self = shift;
    $self->do_command("mouseDown", @_);
}

=item $sel-E<gt>mouse_down_right($locator)

Simulates a user pressing the right mouse button (without releasing it yet) onthe specified element.

=over

$locator is an element locator

=back

=cut

sub mouse_down_right {
    my $self = shift;
    $self->do_command("mouseDownRight", @_);
}

=item $sel-E<gt>mouse_down_at($locator, $coord_string)

Simulates a user pressing the left mouse button (without releasing it yet) atthe specified location.

=over

$locator is an element locator

$coord_string is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.

=back

=cut

sub mouse_down_at {
    my $self = shift;
    $self->do_command("mouseDownAt", @_);
}

=item $sel-E<gt>mouse_down_right_at($locator, $coord_string)

Simulates a user pressing the right mouse button (without releasing it yet) atthe specified location.

=over

$locator is an element locator

$coord_string is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.

=back

=cut

sub mouse_down_right_at {
    my $self = shift;
    $self->do_command("mouseDownRightAt", @_);
}

=item $sel-E<gt>mouse_up($locator)

Simulates the event that occurs when the user releases the mouse button (i.e., stopsholding the button down) on the specified element.

=over

$locator is an element locator

=back

=cut

sub mouse_up {
    my $self = shift;
    $self->do_command("mouseUp", @_);
}

=item $sel-E<gt>mouse_up_right($locator)

Simulates the event that occurs when the user releases the right mouse button (i.e., stopsholding the button down) on the specified element.

=over

$locator is an element locator

=back

=cut

sub mouse_up_right {
    my $self = shift;
    $self->do_command("mouseUpRight", @_);
}

=item $sel-E<gt>mouse_up_at($locator, $coord_string)

Simulates the event that occurs when the user releases the mouse button (i.e., stopsholding the button down) at the specified location.

=over

$locator is an element locator

$coord_string is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.

=back

=cut

sub mouse_up_at {
    my $self = shift;
    $self->do_command("mouseUpAt", @_);
}

=item $sel-E<gt>mouse_up_right_at($locator, $coord_string)

Simulates the event that occurs when the user releases the right mouse button (i.e., stopsholding the button down) at the specified location.

=over

$locator is an element locator

$coord_string is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.

=back

=cut

sub mouse_up_right_at {
    my $self = shift;
    $self->do_command("mouseUpRightAt", @_);
}

=item $sel-E<gt>mouse_move($locator)

Simulates a user pressing the mouse button (without releasing it yet) onthe specified element.

=over

$locator is an element locator

=back

=cut

sub mouse_move {
    my $self = shift;
    $self->do_command("mouseMove", @_);
}

=item $sel-E<gt>mouse_move_at($locator, $coord_string)

Simulates a user pressing the mouse button (without releasing it yet) onthe specified element.

=over

$locator is an element locator

$coord_string is specifies the x,y position (i.e. - 10,20) of the mouse      event relative to the element returned by the locator.

=back

=cut

sub mouse_move_at {
    my $self = shift;
    $self->do_command("mouseMoveAt", @_);
}

=item $sel-E<gt>type($locator, $value)

Sets the value of an input field, as though you typed it in.
Can also be used to set the value of combo boxes, check boxes, etc. In these cases,value should be the value of the option selected, not the visible text.

=over

$locator is an element locator

$value is the value to type

=back

=cut

sub type {
    my $self = shift;
    $self->do_command("type", @_);
}

=item $sel-E<gt>type_keys($locator, $value)

Simulates keystroke events on the specified element, as though you typed the value key-by-key.
This is a convenience method for calling keyDown, keyUp, keyPress for every character in the specified string;this is useful for dynamic UI widgets (like auto-completing combo boxes) that require explicit key events.

Unlike the simple "type" command, which forces the specified value into the page directly, this commandmay or may not have any visible effect, even in cases where typing keys would normally have a visible effect.For example, if you use "typeKeys" on a form element, you may or may not see the results of what you typed inthe field.

In some cases, you may need to use the simple "type" command to set the value of the field and then the "typeKeys" command tosend the keystroke events corresponding to what you just typed.

=over

$locator is an element locator

$value is the value to type

=back

=cut

sub type_keys {
    my $self = shift;
    $self->do_command("typeKeys", @_);
}

=item $sel-E<gt>set_speed($value)

Set execution speed (i.e., set the millisecond length of a delay which will follow each selenium operation).  By default, there is no such delay, i.e.,the delay is 0 milliseconds.

=over

$value is the number of milliseconds to pause after operation

=back

=cut

sub set_speed {
    my $self = shift;
    $self->do_command("setSpeed", @_);
}

=item $sel-E<gt>get_speed()

Get execution speed (i.e., get the millisecond length of the delay following each selenium operation).  By default, there is no such delay, i.e.,the delay is 0 milliseconds.See also setSpeed.

=over

Returns the execution speed in milliseconds.

=back

=cut

sub get_speed {
    my $self = shift;
    return $self->get_string("getSpeed", @_);
}

=item $sel-E<gt>check($locator)

Check a toggle-button (checkbox/radio)

=over

$locator is an element locator

=back

=cut

sub check {
    my $self = shift;
    $self->do_command("check", @_);
}

=item $sel-E<gt>uncheck($locator)

Uncheck a toggle-button (checkbox/radio)

=over

$locator is an element locator

=back

=cut

sub uncheck {
    my $self = shift;
    $self->do_command("uncheck", @_);
}

=item $sel-E<gt>select($select_locator, $option_locator)

Select an option from a drop-down using an option locator.
Option locators provide different ways of specifying options of an HTMLSelect element (e.g. for selecting a specific option, or for assertingthat the selected option satisfies a specification). There are severalforms of Select Option Locator.

=over

=item *

B<label>=I<labelPattern>:matches options based on their labels, i.e. the visible text. (Thisis the default.)

=over

=item *

label=regexp:^[Oo]ther

=back

=item *

B<value>=I<valuePattern>:matches options based on their values.

=over

=item *

value=other

=back

=item *

B<id>=I<id>:matches options based on their ids.

=over

=item *

id=option1

=back

=item *

B<index>=I<index>:matches an option based on its index (offset from zero).

=over

=item *

index=2

=back

=back

If no option locator prefix is provided, the default behaviour is to match on B<label>.

=over

$select_locator is an element locator identifying a drop-down menu

$option_locator is an option locator (a label by default)

=back

=cut

sub select {
    my $self = shift;
    $self->do_command("select", @_);
}

=item $sel-E<gt>add_selection($locator, $option_locator)

Add a selection to the set of selected options in a multi-select element using an option locator.@see #doSelect for details of option locators

=over

$locator is an element locator identifying a multi-select box

$option_locator is an option locator (a label by default)

=back

=cut

sub add_selection {
    my $self = shift;
    $self->do_command("addSelection", @_);
}

=item $sel-E<gt>remove_selection($locator, $option_locator)

Remove a selection from the set of selected options in a multi-select element using an option locator.@see #doSelect for details of option locators

=over

$locator is an element locator identifying a multi-select box

$option_locator is an option locator (a label by default)

=back

=cut

sub remove_selection {
    my $self = shift;
    $self->do_command("removeSelection", @_);
}

=item $sel-E<gt>remove_all_selections($locator)

Unselects all of the selected options in a multi-select element.

=over

$locator is an element locator identifying a multi-select box

=back

=cut

sub remove_all_selections {
    my $self = shift;
    $self->do_command("removeAllSelections", @_);
}

=item $sel-E<gt>submit($form_locator)

Submit the specified form. This is particularly useful for forms withoutsubmit buttons, e.g. single-input "Search" forms.

=over

$form_locator is an element locator for the form you want to submit

=back

=cut

sub submit {
    my $self = shift;
    $self->do_command("submit", @_);
}

=item $sel-E<gt>open($url)

Opens an URL in the test frame. This accepts both relative and absoluteURLs.The "open" command waits for the page to load before proceeding,ie. the "AndWait" suffix is implicit.I<Note>: The URL must be on the same domain as the runner HTMLdue to security restrictions in the browser (Same Origin Policy). If youneed to open an URL on another domain, use the Selenium Server to start anew browser session on that domain.

=over

$url is the URL to open; may be relative or absolute

=back

=cut

sub open {
    my $self = shift;
    $_[0] ||= '/'; # default to opening site root

    $self->do_command("open", @_);
}

=item $sel-E<gt>open_window($url, $window_id)

Opens a popup window (if a window with that ID isn't already open).After opening the window, you'll need to select it using the selectWindowcommand.
This command can also be a useful workaround for bug SEL-339.  In some cases, Selenium will be unable to intercept a call to window.open (if the call occurs during or before the "onLoad" event, for example).In those cases, you can force Selenium to notice the open window's name by using the Selenium openWindow command, usingan empty (blank) url, like this: openWindow("", "myFunnyWindow").

=over

$url is the URL to open, which can be blank

$window_id is the JavaScript window ID of the window to select

=back

=cut

sub open_window {
    my $self = shift;
    $self->do_command("openWindow", @_);
}

=item $sel-E<gt>select_window($window_id)

Selects a popup window using a window locator; once a popup window has been selected, allcommands go to that window. To select the main window again, use nullas the target.
Window locators provide different ways of specifying the window object:by title, by internal JavaScript "name," or by JavaScript variable.

=over

=item *

B<title>=I<My Special Window>:Finds the window using the text that appears in the title bar.  Be careful;two windows can share the same title.  If that happens, this locator willjust pick one.

=item *

B<name>=I<myWindow>:Finds the window using its internal JavaScript "name" property.  This is the second parameter "windowName" passed to the JavaScript method window.open(url, windowName, windowFeatures, replaceFlag)(which Selenium intercepts).

=item *

B<var>=I<variableName>:Some pop-up windows are unnamed (anonymous), but are associated with a JavaScript variable name in the currentapplication window, e.g. "window.foo = window.open(url);".  In those cases, you can open the window using"var=foo".

=back

If no window locator prefix is provided, we'll try to guess what you mean like this:

1.) if windowID is null, (or the string "null") then it is assumed the user is referring to the original window instantiated by the browser).

2.) if the value of the "windowID" parameter is a JavaScript variable name in the current application window, then it is assumedthat this variable contains the return value from a call to the JavaScript window.open() method.

3.) Otherwise, selenium looks in a hash it maintains that maps string names to window "names".

4.) If I<that> fails, we'll try looping over all of the known windows to try to find the appropriate "title".Since "title" is not necessarily unique, this may have unexpected behavior.

If you're having trouble figuring out the name of a window that you want to manipulate, look at the Selenium log messageswhich identify the names of windows created via window.open (and therefore intercepted by Selenium).  You will see messageslike the following for each window as it is opened:

C<debug: window.open call intercepted; window ID (which you can use with selectWindow()) is "myNewWindow">

In some cases, Selenium will be unable to intercept a call to window.open (if the call occurs during or before the "onLoad" event, for example).(This is bug SEL-339.)  In those cases, you can force Selenium to notice the open window's name by using the Selenium openWindow command, usingan empty (blank) url, like this: openWindow("", "myFunnyWindow").

=over

$window_id is the JavaScript window ID of the window to select

=back

=cut

sub select_window {
    my $self = shift;
    $self->do_command("selectWindow", @_);
}

=item $sel-E<gt>select_frame($locator)

Selects a frame within the current window.  (You may invoke this commandmultiple times to select nested frames.)  To select the parent frame, use"relative=parent" as a locator; to select the top frame, use "relative=top".You can also select a frame by its 0-based index number; select the first frame with"index=0", or the third frame with "index=2".
You may also use a DOM expression to identify the frame you want directly,like this: C<dom=frames["main"].frames["subframe"]>

=over

$locator is an element locator identifying a frame or iframe

=back

=cut

sub select_frame {
    my $self = shift;
    $self->do_command("selectFrame", @_);
}

=item $sel-E<gt>get_whether_this_frame_match_frame_expression($current_frame_string, $target)

Determine whether current/locator identify the frame containing this running code.
This is useful in proxy injection mode, where this code runs in everybrowser frame and window, and sometimes the selenium server needs to identifythe "current" frame.  In this case, when the test calls selectFrame, thisroutine is called for each frame to figure out which one has been selected.The selected frame will return true, while all others will return false.

=over

$current_frame_string is starting frame

$target is new frame (which might be relative to the current one)

=back

=over

Returns true if the new frame is this code's window

=back

=cut

sub get_whether_this_frame_match_frame_expression {
    my $self = shift;
    return $self->get_boolean("getWhetherThisFrameMatchFrameExpression", @_);
}

=item $sel-E<gt>get_whether_this_window_match_window_expression($current_window_string, $target)

Determine whether currentWindowString plus target identify the window containing this running code.
This is useful in proxy injection mode, where this code runs in everybrowser frame and window, and sometimes the selenium server needs to identifythe "current" window.  In this case, when the test calls selectWindow, thisroutine is called for each window to figure out which one has been selected.The selected window will return true, while all others will return false.

=over

$current_window_string is starting window

$target is new window (which might be relative to the current one, e.g., "_parent")

=back

=over

Returns true if the new window is this code's window

=back

=cut

sub get_whether_this_window_match_window_expression {
    my $self = shift;
    return $self->get_boolean("getWhetherThisWindowMatchWindowExpression", @_);
}

=item $sel-E<gt>wait_for_pop_up($window_id, $timeout)

Waits for a popup window to appear and load up.

=over

$window_id is the JavaScript window "name" of the window that will appear (not the text of the title bar)

$timeout is a timeout in milliseconds, after which the action will return with an error

=back

=cut

sub wait_for_pop_up {
    my $self = shift;
    $self->do_command("waitForPopUp", @_);
}

=item $sel-E<gt>choose_cancel_on_next_confirmation()

By default, Selenium's overridden window.confirm() function willreturn true, as if the user had manually clicked OK; after runningthis command, the next call to confirm() will return false, as ifthe user had clicked Cancel.  Selenium will then resume using thedefault behavior for future confirmations, automatically returning true (OK) unless/until you explicitly call this command for eachconfirmation.

Take note - every time a confirmation comes up, you mustconsume it with a corresponding getConfirmation, or elsethe next selenium operation will fail.

=cut

sub choose_cancel_on_next_confirmation {
    my $self = shift;
    $self->do_command("chooseCancelOnNextConfirmation", @_);
}

=item $sel-E<gt>choose_ok_on_next_confirmation()

Undo the effect of calling chooseCancelOnNextConfirmation.  Notethat Selenium's overridden window.confirm() function will normally automaticallyreturn true, as if the user had manually clicked OK, so you shouldn'tneed to use this command unless for some reason you need to changeyour mind prior to the next confirmation.  After any confirmation, Selenium will resume using thedefault behavior for future confirmations, automatically returning true (OK) unless/until you explicitly call chooseCancelOnNextConfirmation for eachconfirmation.

Take note - every time a confirmation comes up, you mustconsume it with a corresponding getConfirmation, or elsethe next selenium operation will fail.

=cut

sub choose_ok_on_next_confirmation {
    my $self = shift;
    $self->do_command("chooseOkOnNextConfirmation", @_);
}

=item $sel-E<gt>answer_on_next_prompt($answer)

Instructs Selenium to return the specified answer string in response tothe next JavaScript prompt [window.prompt()].

=over

$answer is the answer to give in response to the prompt pop-up

=back

=cut

sub answer_on_next_prompt {
    my $self = shift;
    $self->do_command("answerOnNextPrompt", @_);
}

=item $sel-E<gt>go_back()

Simulates the user clicking the "back" button on their browser.

=cut

sub go_back {
    my $self = shift;
    $self->do_command("goBack", @_);
}

=item $sel-E<gt>refresh()

Simulates the user clicking the "Refresh" button on their browser.

=cut

sub refresh {
    my $self = shift;
    $self->do_command("refresh", @_);
}

=item $sel-E<gt>close()

Simulates the user clicking the "close" button in the titlebar of a popupwindow or tab.

=cut

sub close {
    my $self = shift;
    $self->do_command("close", @_);
}

=item $sel-E<gt>is_alert_present()

Has an alert occurred?
This function never throws an exception

=over

Returns true if there is an alert

=back

=cut

sub is_alert_present {
    my $self = shift;
    return $self->get_boolean("isAlertPresent", @_);
}

=item $sel-E<gt>is_prompt_present()

Has a prompt occurred?
This function never throws an exception

=over

Returns true if there is a pending prompt

=back

=cut

sub is_prompt_present {
    my $self = shift;
    return $self->get_boolean("isPromptPresent", @_);
}

=item $sel-E<gt>is_confirmation_present()

Has confirm() been called?
This function never throws an exception

=over

Returns true if there is a pending confirmation

=back

=cut

sub is_confirmation_present {
    my $self = shift;
    return $self->get_boolean("isConfirmationPresent", @_);
}

=item $sel-E<gt>get_alert()

Retrieves the message of a JavaScript alert generated during the previous action, or fail if there were no alerts.
Getting an alert has the same effect as manually clicking OK. If analert is generated but you do not consume it with getAlert, the next Selenium actionwill fail.

Under Selenium, JavaScript alerts will NOT pop up a visible alertdialog.

Selenium does NOT support JavaScript alerts that are generated in apage's onload() event handler. In this case a visible dialog WILL begenerated and Selenium will hang until someone manually clicks OK.

=over

Returns The message of the most recent JavaScript alert

=back

=cut

sub get_alert {
    my $self = shift;
    return $self->get_string("getAlert", @_);
}

=item $sel-E<gt>get_confirmation()

Retrieves the message of a JavaScript confirmation dialog generated duringthe previous action.
By default, the confirm function will return true, having the same effectas manually clicking OK. This can be changed by prior execution of thechooseCancelOnNextConfirmation command. 

If an confirmation is generated but you do not consume it with getConfirmation,the next Selenium action will fail.

NOTE: under Selenium, JavaScript confirmations will NOT pop up a visibledialog.

NOTE: Selenium does NOT support JavaScript confirmations that aregenerated in a page's onload() event handler. In this case a visibledialog WILL be generated and Selenium will hang until you manually clickOK.

=over

Returns the message of the most recent JavaScript confirmation dialog

=back

=cut

sub get_confirmation {
    my $self = shift;
    return $self->get_string("getConfirmation", @_);
}

=item $sel-E<gt>get_prompt()

Retrieves the message of a JavaScript question prompt dialog generated duringthe previous action.
Successful handling of the prompt requires prior execution of theanswerOnNextPrompt command. If a prompt is generated but youdo not get/verify it, the next Selenium action will fail.

NOTE: under Selenium, JavaScript prompts will NOT pop up a visibledialog.

NOTE: Selenium does NOT support JavaScript prompts that are generated in apage's onload() event handler. In this case a visible dialog WILL begenerated and Selenium will hang until someone manually clicks OK.

=over

Returns the message of the most recent JavaScript question prompt

=back

=cut

sub get_prompt {
    my $self = shift;
    return $self->get_string("getPrompt", @_);
}

=item $sel-E<gt>get_location()

Gets the absolute URL of the current page.

=over

Returns the absolute URL of the current page

=back

=cut

sub get_location {
    my $self = shift;
    return $self->get_string("getLocation", @_);
}

=item $sel-E<gt>get_title()

Gets the title of the current page.

=over

Returns the title of the current page

=back

=cut

sub get_title {
    my $self = shift;
    return $self->get_string("getTitle", @_);
}

=item $sel-E<gt>get_body_text()

Gets the entire text of the page.

=over

Returns the entire text of the page

=back

=cut

sub get_body_text {
    my $self = shift;
    return $self->get_string("getBodyText", @_);
}

=item $sel-E<gt>get_value($locator)

Gets the (whitespace-trimmed) value of an input field (or anything else with a value parameter).For checkbox/radio elements, the value will be "on" or "off" depending onwhether the element is checked or not.

=over

$locator is an element locator

=back

=over

Returns the element value, or "on/off" for checkbox/radio elements

=back

=cut

sub get_value {
    my $self = shift;
    return $self->get_string("getValue", @_);
}

=item $sel-E<gt>get_text($locator)

Gets the text of an element. This works for any element that containstext. This command uses either the textContent (Mozilla-like browsers) orthe innerText (IE-like browsers) of the element, which is the renderedtext shown to the user.

=over

$locator is an element locator

=back

=over

Returns the text of the element

=back

=cut

sub get_text {
    my $self = shift;
    return $self->get_string("getText", @_);
}

=item $sel-E<gt>highlight($locator)

Briefly changes the backgroundColor of the specified element yellow.  Useful for debugging.

=over

$locator is an element locator

=back

=cut

sub highlight {
    my $self = shift;
    $self->do_command("highlight", @_);
}

=item $sel-E<gt>get_eval($script)

Gets the result of evaluating the specified JavaScript snippet.  The snippet mayhave multiple lines, but only the result of the last line will be returned.
Note that, by default, the snippet will run in the context of the "selenium"object itself, so C<this> will refer to the Selenium object.  Use C<window> torefer to the window of your application, e.g. C<window.document.getElementById('foo')>

If you need to usea locator to refer to a single element in your application page, you canuse C<this.browserbot.findElement("id=foo")> where "id=foo" is your locator.

=over

$script is the JavaScript snippet to run

=back

=over

Returns the results of evaluating the snippet

=back

=cut

sub get_eval {
    my $self = shift;
    return $self->get_string("getEval", @_);
}

=item $sel-E<gt>is_checked($locator)

Gets whether a toggle-button (checkbox/radio) is checked.  Fails if the specified element doesn't exist or isn't a toggle-button.

=over

$locator is an element locator pointing to a checkbox or radio button

=back

=over

Returns true if the checkbox is checked, false otherwise

=back

=cut

sub is_checked {
    my $self = shift;
    return $self->get_boolean("isChecked", @_);
}

=item $sel-E<gt>get_table($table_cell_address)

Gets the text from a cell of a table. The cellAddress syntaxtableLocator.row.column, where row and column start at 0.

=over

$table_cell_address is a cell address, e.g. "foo.1.4"

=back

=over

Returns the text from the specified cell

=back

=cut

sub get_table {
    my $self = shift;
    return $self->get_string("getTable", @_);
}

=item $sel-E<gt>get_selected_labels($select_locator)

Gets all option labels (visible text) for selected options in the specified select or multi-select element.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns an array of all selected option labels in the specified select drop-down

=back

=cut

sub get_selected_labels {
    my $self = shift;
    return $self->get_string_array("getSelectedLabels", @_);
}

=item $sel-E<gt>get_selected_label($select_locator)

Gets option label (visible text) for selected option in the specified select element.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns the selected option label in the specified select drop-down

=back

=cut

sub get_selected_label {
    my $self = shift;
    return $self->get_string("getSelectedLabel", @_);
}

=item $sel-E<gt>get_selected_values($select_locator)

Gets all option values (value attributes) for selected options in the specified select or multi-select element.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns an array of all selected option values in the specified select drop-down

=back

=cut

sub get_selected_values {
    my $self = shift;
    return $self->get_string_array("getSelectedValues", @_);
}

=item $sel-E<gt>get_selected_value($select_locator)

Gets option value (value attribute) for selected option in the specified select element.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns the selected option value in the specified select drop-down

=back

=cut

sub get_selected_value {
    my $self = shift;
    return $self->get_string("getSelectedValue", @_);
}

=item $sel-E<gt>get_selected_indexes($select_locator)

Gets all option indexes (option number, starting at 0) for selected options in the specified select or multi-select element.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns an array of all selected option indexes in the specified select drop-down

=back

=cut

sub get_selected_indexes {
    my $self = shift;
    return $self->get_string_array("getSelectedIndexes", @_);
}

=item $sel-E<gt>get_selected_index($select_locator)

Gets option index (option number, starting at 0) for selected option in the specified select element.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns the selected option index in the specified select drop-down

=back

=cut

sub get_selected_index {
    my $self = shift;
    return $self->get_string("getSelectedIndex", @_);
}

=item $sel-E<gt>get_selected_ids($select_locator)

Gets all option element IDs for selected options in the specified select or multi-select element.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns an array of all selected option IDs in the specified select drop-down

=back

=cut

sub get_selected_ids {
    my $self = shift;
    return $self->get_string_array("getSelectedIds", @_);
}

=item $sel-E<gt>get_selected_id($select_locator)

Gets option element ID for selected option in the specified select element.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns the selected option ID in the specified select drop-down

=back

=cut

sub get_selected_id {
    my $self = shift;
    return $self->get_string("getSelectedId", @_);
}

=item $sel-E<gt>is_something_selected($select_locator)

Determines whether some option in a drop-down menu is selected.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns true if some option has been selected, false otherwise

=back

=cut

sub is_something_selected {
    my $self = shift;
    return $self->get_boolean("isSomethingSelected", @_);
}

=item $sel-E<gt>get_select_options($select_locator)

Gets all option labels in the specified select drop-down.

=over

$select_locator is an element locator identifying a drop-down menu

=back

=over

Returns an array of all option labels in the specified select drop-down

=back

=cut

sub get_select_options {
    my $self = shift;
    return $self->get_string_array("getSelectOptions", @_);
}

=item $sel-E<gt>get_attribute($attribute_locator)

Gets the value of an element attribute. The value of the attribute maydiffer across browsers (this is the case for the "style" attribute, forexample).

=over

$attribute_locator is an element locator followed by an @ sign and then the name of the attribute, e.g. "foo@bar"

=back

=over

Returns the value of the specified attribute

=back

=cut

sub get_attribute {
    my $self = shift;
    return $self->get_string("getAttribute", @_);
}

=item $sel-E<gt>is_text_present($pattern)

Verifies that the specified text pattern appears somewhere on the rendered page shown to the user.

=over

$pattern is a pattern to match with the text of the page

=back

=over

Returns true if the pattern matches the text, false otherwise

=back

=cut

sub is_text_present {
    my $self = shift;
    return $self->get_boolean("isTextPresent", @_);
}

=item $sel-E<gt>is_element_present($locator)

Verifies that the specified element is somewhere on the page.

=over

$locator is an element locator

=back

=over

Returns true if the element is present, false otherwise

=back

=cut

sub is_element_present {
    my $self = shift;
    return $self->get_boolean("isElementPresent", @_);
}

=item $sel-E<gt>is_visible($locator)

Determines if the specified element is visible. Anelement can be rendered invisible by setting the CSS "visibility"property to "hidden", or the "display" property to "none", either for theelement itself or one if its ancestors.  This method will fail ifthe element is not present.

=over

$locator is an element locator

=back

=over

Returns true if the specified element is visible, false otherwise

=back

=cut

sub is_visible {
    my $self = shift;
    return $self->get_boolean("isVisible", @_);
}

=item $sel-E<gt>is_editable($locator)

Determines whether the specified input element is editable, ie hasn't been disabled.This method will fail if the specified element isn't an input element.

=over

$locator is an element locator

=back

=over

Returns true if the input element is editable, false otherwise

=back

=cut

sub is_editable {
    my $self = shift;
    return $self->get_boolean("isEditable", @_);
}

=item $sel-E<gt>get_all_buttons()

Returns the IDs of all buttons on the page.
If a given button has no ID, it will appear as "" in this array.

=over

Returns the IDs of all buttons on the page

=back

=cut

sub get_all_buttons {
    my $self = shift;
    return $self->get_string_array("getAllButtons", @_);
}

=item $sel-E<gt>get_all_links()

Returns the IDs of all links on the page.
If a given link has no ID, it will appear as "" in this array.

=over

Returns the IDs of all links on the page

=back

=cut

sub get_all_links {
    my $self = shift;
    return $self->get_string_array("getAllLinks", @_);
}

=item $sel-E<gt>get_all_fields()

Returns the IDs of all input fields on the page.
If a given field has no ID, it will appear as "" in this array.

=over

Returns the IDs of all field on the page

=back

=cut

sub get_all_fields {
    my $self = shift;
    return $self->get_string_array("getAllFields", @_);
}

=item $sel-E<gt>get_attribute_from_all_windows($attribute_name)

Returns every instance of some attribute from all known windows.

=over

$attribute_name is name of an attribute on the windows

=back

=over

Returns the set of values of this attribute from all known windows.

=back

=cut

sub get_attribute_from_all_windows {
    my $self = shift;
    return $self->get_string_array("getAttributeFromAllWindows", @_);
}

=item $sel-E<gt>dragdrop($locator, $movements_string)

deprecated - use dragAndDrop instead

=over

$locator is an element locator

$movements_string is offset in pixels from the current location to which the element should be moved, e.g., "+70,-300"

=back

=cut

sub dragdrop {
    my $self = shift;
    $self->do_command("dragdrop", @_);
}

=item $sel-E<gt>set_mouse_speed($pixels)

Configure the number of pixels between "mousemove" events during dragAndDrop commands (default=10).
Setting this value to 0 means that we'll send a "mousemove" event to every single pixelin between the start location and the end location; that can be very slow, and maycause some browsers to force the JavaScript to timeout.

If the mouse speed is greater than the distance between the two dragged objects, we'lljust send one "mousemove" at the start location and then one final one at the end location.

=over

$pixels is the number of pixels between "mousemove" events

=back

=cut

sub set_mouse_speed {
    my $self = shift;
    $self->do_command("setMouseSpeed", @_);
}

=item $sel-E<gt>get_mouse_speed()

Returns the number of pixels between "mousemove" events during dragAndDrop commands (default=10).

=over

Returns the number of pixels between "mousemove" events during dragAndDrop commands (default=10)

=back

=cut

sub get_mouse_speed {
    my $self = shift;
    return $self->get_number("getMouseSpeed", @_);
}

=item $sel-E<gt>drag_and_drop($locator, $movements_string)

Drags an element a certain distance and then drops it

=over

$locator is an element locator

$movements_string is offset in pixels from the current location to which the element should be moved, e.g., "+70,-300"

=back

=cut

sub drag_and_drop {
    my $self = shift;
    $self->do_command("dragAndDrop", @_);
}

=item $sel-E<gt>drag_and_drop_to_object($locator_of_object_to_be_dragged, $locator_of_drag_destination_object)

Drags an element and drops it on another element

=over

$locator_of_object_to_be_dragged is an element to be dragged

$locator_of_drag_destination_object is an element whose location (i.e., whose center-most pixel) will be the point where locatorOfObjectToBeDragged  is dropped

=back

=cut

sub drag_and_drop_to_object {
    my $self = shift;
    $self->do_command("dragAndDropToObject", @_);
}

=item $sel-E<gt>window_focus()

Gives focus to the currently selected window

=cut

sub window_focus {
    my $self = shift;
    $self->do_command("windowFocus", @_);
}

=item $sel-E<gt>window_maximize()

Resize currently selected window to take up the entire screen

=cut

sub window_maximize {
    my $self = shift;
    $self->do_command("windowMaximize", @_);
}

=item $sel-E<gt>get_all_window_ids()

Returns the IDs of all windows that the browser knows about.

=over

Returns the IDs of all windows that the browser knows about.

=back

=cut

sub get_all_window_ids {
    my $self = shift;
    return $self->get_string_array("getAllWindowIds", @_);
}

=item $sel-E<gt>get_all_window_names()

Returns the names of all windows that the browser knows about.

=over

Returns the names of all windows that the browser knows about.

=back

=cut

sub get_all_window_names {
    my $self = shift;
    return $self->get_string_array("getAllWindowNames", @_);
}

=item $sel-E<gt>get_all_window_titles()

Returns the titles of all windows that the browser knows about.

=over

Returns the titles of all windows that the browser knows about.

=back

=cut

sub get_all_window_titles {
    my $self = shift;
    return $self->get_string_array("getAllWindowTitles", @_);
}

=item $sel-E<gt>get_html_source()

Returns the entire HTML source between the opening andclosing "html" tags.

=over

Returns the entire HTML source

=back

=cut

sub get_html_source {
    my $self = shift;
    return $self->get_string("getHtmlSource", @_);
}

=item $sel-E<gt>set_cursor_position($locator, $position)

Moves the text cursor to the specified position in the given input element or textarea.This method will fail if the specified element isn't an input element or textarea.

=over

$locator is an element locator pointing to an input element or textarea

$position is the numerical position of the cursor in the field; position should be 0 to move the position to the beginning of the field.  You can also set the cursor to -1 to move it to the end of the field.

=back

=cut

sub set_cursor_position {
    my $self = shift;
    $self->do_command("setCursorPosition", @_);
}

=item $sel-E<gt>get_element_index($locator)

Get the relative index of an element to its parent (starting from 0). The comment node and empty text nodewill be ignored.

=over

$locator is an element locator pointing to an element

=back

=over

Returns of relative index of the element to its parent (starting from 0)

=back

=cut

sub get_element_index {
    my $self = shift;
    return $self->get_number("getElementIndex", @_);
}

=item $sel-E<gt>is_ordered($locator1, $locator2)

Check if these two elements have same parent and are ordered siblings in the DOM. Two same elements willnot be considered ordered.

=over

$locator1 is an element locator pointing to the first element

$locator2 is an element locator pointing to the second element

=back

=over

Returns true if element1 is the previous sibling of element2, false otherwise

=back

=cut

sub is_ordered {
    my $self = shift;
    return $self->get_boolean("isOrdered", @_);
}

=item $sel-E<gt>get_element_position_left($locator)

Retrieves the horizontal position of an element

=over

$locator is an element locator pointing to an element OR an element itself

=back

=over

Returns of pixels from the edge of the frame.

=back

=cut

sub get_element_position_left {
    my $self = shift;
    return $self->get_number("getElementPositionLeft", @_);
}

=item $sel-E<gt>get_element_position_top($locator)

Retrieves the vertical position of an element

=over

$locator is an element locator pointing to an element OR an element itself

=back

=over

Returns of pixels from the edge of the frame.

=back

=cut

sub get_element_position_top {
    my $self = shift;
    return $self->get_number("getElementPositionTop", @_);
}

=item $sel-E<gt>get_element_width($locator)

Retrieves the width of an element

=over

$locator is an element locator pointing to an element

=back

=over

Returns width of an element in pixels

=back

=cut

sub get_element_width {
    my $self = shift;
    return $self->get_number("getElementWidth", @_);
}

=item $sel-E<gt>get_element_height($locator)

Retrieves the height of an element

=over

$locator is an element locator pointing to an element

=back

=over

Returns height of an element in pixels

=back

=cut

sub get_element_height {
    my $self = shift;
    return $self->get_number("getElementHeight", @_);
}

=item $sel-E<gt>get_cursor_position($locator)

Retrieves the text cursor position in the given input element or textarea; beware, this may not work perfectly on all browsers.
Specifically, if the cursor/selection has been cleared by JavaScript, this command will tend toreturn the position of the last location of the cursor, even though the cursor is now gone from the page.  This is filed as http://jira.openqa.org/browse/SEL-243 (SEL-243).
This method will fail if the specified element isn't an input element or textarea, or there is no cursor in the element.

=over

$locator is an element locator pointing to an input element or textarea

=back

=over

Returns the numerical position of the cursor in the field

=back

=cut

sub get_cursor_position {
    my $self = shift;
    return $self->get_number("getCursorPosition", @_);
}

=item $sel-E<gt>get_expression($expression)

Returns the specified expression.
This is useful because of JavaScript preprocessing.It is used to generate commands like assertExpression and waitForExpression.

=over

$expression is the value to return

=back

=over

Returns the value passed in

=back

=cut

sub get_expression {
    my $self = shift;
    return $self->get_string("getExpression", @_);
}

=item $sel-E<gt>get_xpath_count($xpath)

Returns the number of nodes that match the specified xpath, eg. "//table" would givethe number of tables.

=over

$xpath is the xpath expression to evaluate. do NOT wrap this expression in a 'count()' function; we will do that for you.

=back

=over

Returns the number of nodes that match the specified xpath

=back

=cut

sub get_xpath_count {
    my $self = shift;
    return $self->get_number("getXpathCount", @_);
}

=item $sel-E<gt>assign_id($locator, $identifier)

Temporarily sets the "id" attribute of the specified element, so you can locate it in the futureusing its ID rather than a slow/complicated XPath.  This ID will disappear once the page isreloaded.

=over

$locator is an element locator pointing to an element

$identifier is a string to be used as the ID of the specified element

=back

=cut

sub assign_id {
    my $self = shift;
    $self->do_command("assignId", @_);
}

=item $sel-E<gt>allow_native_xpath($allow)

Specifies whether Selenium should use the native in-browser implementationof XPath (if any native version is available); if you pass "false" tothis function, we will always use our pure-JavaScript xpath library.Using the pure-JS xpath library can improve the consistency of xpathelement locators between different browser vendors, but the pure-JSversion is much slower than the native implementations.

=over

$allow is boolean, true means we'll prefer to use native XPath; false means we'll only use JS XPath

=back

=cut

sub allow_native_xpath {
    my $self = shift;
    $self->do_command("allowNativeXpath", @_);
}

=item $sel-E<gt>ignore_attributes_without_value($ignore)

Specifies whether Selenium will ignore xpath attributes that have novalue, i.e. are the empty string, when using the non-native xpathevaluation engine. You'd want to do this for performance reasons in IE.However, this could break certain xpaths, for example an xpath that looksfor an attribute whose value is NOT the empty string.The hope is that such xpaths are relatively rare, but the user shouldhave the option of using them. Note that this only influences xpathevaluation when using the ajaxslt engine (i.e. not "javascript-xpath").

=over

$ignore is boolean, true means we'll ignore attributes without value                        at the expense of xpath "correctness"; false means                        we'll sacrifice speed for correctness.

=back

=cut

sub ignore_attributes_without_value {
    my $self = shift;
    $self->do_command("ignoreAttributesWithoutValue", @_);
}

=item $sel-E<gt>wait_for_condition($script, $timeout)

Runs the specified JavaScript snippet repeatedly until it evaluates to "true".The snippet may have multiple lines, but only the result of the last linewill be considered.
Note that, by default, the snippet will be run in the runner's test window, not in the windowof your application.  To get the window of your application, you can usethe JavaScript snippet C<selenium.browserbot.getCurrentWindow()>, and thenrun your JavaScript in there

=over

$script is the JavaScript snippet to run

$timeout is a timeout in milliseconds, after which this command will return with an error

=back

=cut

sub wait_for_condition {
    my $self = shift;
    $self->do_command("waitForCondition", @_);
}

=item $sel-E<gt>set_timeout($timeout)

Specifies the amount of time that Selenium will wait for actions to complete.
Actions that require waiting include "open" and the "waitFor*" actions.
The default timeout is 30 seconds.

=over

$timeout is a timeout in milliseconds, after which the action will return with an error

=back

=cut

sub set_timeout {
    my $self = shift;
    $self->do_command("setTimeout", @_);
}

=item $sel-E<gt>wait_for_page_to_load($timeout)

Waits for a new page to load.
You can use this command instead of the "AndWait" suffixes, "clickAndWait", "selectAndWait", "typeAndWait" etc.(which are only available in the JS API).

Selenium constantly keeps track of new pages loading, and sets a "newPageLoaded"flag when it first notices a page load.  Running any other Selenium command afterturns the flag to false.  Hence, if you want to wait for a page to load, you mustwait immediately after a Selenium command that caused a page-load.

=over

$timeout is a timeout in milliseconds, after which this command will return with an error

=back

=cut

sub wait_for_page_to_load {
    my $self = shift;
    $self->do_command("waitForPageToLoad", @_);
}

=item $sel-E<gt>wait_for_frame_to_load($frame_address, $timeout)

Waits for a new frame to load.
Selenium constantly keeps track of new pages and frames loading, and sets a "newPageLoaded" flag when it first notices a page load.
See waitForPageToLoad for more information.

=over

$frame_address is FrameAddress from the server side

$timeout is a timeout in milliseconds, after which this command will return with an error

=back

=cut

sub wait_for_frame_to_load {
    my $self = shift;
    $self->do_command("waitForFrameToLoad", @_);
}

=item $sel-E<gt>get_cookie()

Return all cookies of the current page under test.

=over

Returns all cookies of the current page under test

=back

=cut

sub get_cookie {
    my $self = shift;
    return $self->get_string("getCookie", @_);
}

=item $sel-E<gt>get_cookie_by_name($name)

Returns the value of the cookie with the specified name, or throws an error if the cookie is not present.

=over

$name is the name of the cookie

=back

=over

Returns the value of the cookie

=back

=cut

sub get_cookie_by_name {
    my $self = shift;
    return $self->get_string("getCookieByName", @_);
}

=item $sel-E<gt>is_cookie_present($name)

Returns true if a cookie with the specified name is present, or false otherwise.

=over

$name is the name of the cookie

=back

=over

Returns true if a cookie with the specified name is present, or false otherwise.

=back

=cut

sub is_cookie_present {
    my $self = shift;
    return $self->get_boolean("isCookiePresent", @_);
}

=item $sel-E<gt>create_cookie($name_value_pair, $options_string)

Create a new cookie whose path and domain are same with those of current pageunder test, unless you specified a path for this cookie explicitly.

=over

$name_value_pair is name and value of the cookie in a format "name=value"

$options_string is options for the cookie. Currently supported options include 'path', 'max_age' and 'domain'.      the optionsString's format is "path=/path/, max_age=60, domain=.foo.com". The order of options are irrelevant, the unit      of the value of 'max_age' is second.  Note that specifying a domain that isn't a subset of the current domain will      usually fail.

=back

=cut

sub create_cookie {
    my $self = shift;
    $self->do_command("createCookie", @_);
}

=item $sel-E<gt>delete_cookie($name, $options_string)

Delete a named cookie with specified path and domain.  Be careful; to delete a cookie, youneed to delete it using the exact same path and domain that were used to create the cookie.If the path is wrong, or the domain is wrong, the cookie simply won't be deleted.  Alsonote that specifying a domain that isn't a subset of the current domain will usually fail.Since there's no way to discover at runtime the original path and domain of a given cookie,we've added an option called 'recurse' to try all sub-domains of the current domain withall paths that are a subset of the current path.  Beware; this option can be slow.  Inbig-O notation, it operates in O(n*m) time, where n is the number of dots in the domainname and m is the number of slashes in the path.

=over

$name is the name of the cookie to be deleted

$options_string is options for the cookie. Currently supported options include 'path', 'domain'      and 'recurse.' The optionsString's format is "path=/path/, domain=.foo.com, recurse=true".      The order of options are irrelevant. Note that specifying a domain that isn't a subset of      the current domain will usually fail.

=back

=cut

sub delete_cookie {
    my $self = shift;
    $self->do_command("deleteCookie", @_);
}

=item $sel-E<gt>delete_all_visible_cookies()

Calls deleteCookie with recurse=true on all cookies visible to the current page.As noted on the documentation for deleteCookie, recurse=true can be much slowerthan simply deleting the cookies using a known domain/path.

=cut

sub delete_all_visible_cookies {
    my $self = shift;
    $self->do_command("deleteAllVisibleCookies", @_);
}

=item $sel-E<gt>set_browser_log_level($log_level)

Sets the threshold for browser-side logging messages; log messages beneath this threshold will be discarded.Valid logLevel strings are: "debug", "info", "warn", "error" or "off".To see the browser logs, you need toeither show the log window in GUI mode, or enable browser-side logging in Selenium RC.

=over

$log_level is one of the following: "debug", "info", "warn", "error" or "off"

=back

=cut

sub set_browser_log_level {
    my $self = shift;
    $self->do_command("setBrowserLogLevel", @_);
}

=item $sel-E<gt>run_script($script)

Creates a new "script" tag in the body of the current test window, and adds the specified text into the body of the command.  Scripts run inthis way can often be debugged more easily than scripts executed usingSelenium's "getEval" command.  Beware that JS exceptions thrown in these scripttags aren't managed by Selenium, so you should probably wrap your scriptin try/catch blocks if there is any chance that the script will throwan exception.

=over

$script is the JavaScript snippet to run

=back

=cut

sub run_script {
    my $self = shift;
    $self->do_command("runScript", @_);
}

=item $sel-E<gt>add_location_strategy($strategy_name)

Defines a new function for Selenium to locate elements on the page.For example,if you define the strategy "foo", and someone runs click("foo=blah"), we'llrun your function, passing you the string "blah", and click on the element that your functionreturns, or throw an "Element not found" error if your function returns null.We'll pass three arguments to your function:

=over

=item *

locator: the string the user passed in

=item *

inWindow: the currently selected window

=item *

inDocument: the currently selected document

=back

The function must return null if the element can't be found.

=over

$strategy_name is the name of the strategy to define; this should use only   letters [a-zA-Z] with no spaces or other punctuation.

=back

=cut

sub add_location_strategy {
    my $self = shift;
    $self->do_command("addLocationStrategy", @_);
}

=item $sel-E<gt>capture_entire_page_screenshot($filename, $kwargs)

Saves the entire contents of the current window canvas to a PNG file.Contrast this with the captureScreenshot command, which captures thecontents of the OS viewport (i.e. whatever is currently being displayedon the monitor), and is implemented in the RC only. Currently this onlyworks in Firefox when running in chrome mode, and in IE non-HTA usingthe EXPERIMENTAL "Snapsie" utility. The Firefox implementation is mostlyborrowed from the Screengrab! Firefox extension. Please seehttp://www.screengrab.org and http://snapsie.sourceforge.net/ fordetails.

=over

$filename is the path to the file to persist the screenshot as. No                  filename extension will be appended by default.                  Directories will not be created if they do not exist,                    and an exception will be thrown, possibly by native                  code.

$kwargs is a kwargs string that modifies the way the screenshot                  is captured. Example: "background=#CCFFDD" .                  Currently valid options:                                     =item background
                     
the background CSS for the HTML document. This                     may be useful to set for capturing screenshots of                     less-than-ideal layouts, for example where absolute                     positioning causes the calculation of the canvas                     dimension to fail and a black background is exposed                     (possibly obscuring black text).
                  

=back

=cut

sub capture_entire_page_screenshot {
    my $self = shift;
    $self->do_command("captureEntirePageScreenshot", @_);
}

=item $sel-E<gt>rollup($rollup_name, $kwargs)

Executes a command rollup, which is a series of commands with a uniquename, and optionally arguments that control the generation of the set ofcommands. If any one of the rolled-up commands fails, the rollup isconsidered to have failed. Rollups may also contain nested rollups.

=over

$rollup_name is the name of the rollup command

$kwargs is keyword arguments string that influences how the                    rollup expands into commands

=back

=cut

sub rollup {
    my $self = shift;
    $self->do_command("rollup", @_);
}

=item $sel-E<gt>add_script($script_content, $script_tag_id)

Loads script content into a new script tag in the Selenium document. Thisdiffers from the runScript command in that runScript adds the script tagto the document of the AUT, not the Selenium document. The followingentities in the script content are replaced by the characters theyrepresent:    &lt;    &gt;    &amp;The corresponding remove command is removeScript.

=over

$script_content is the Javascript content of the script to add

$script_tag_id is (optional) the id of the new script tag. If                       specified, and an element with this id already                       exists, this operation will fail.

=back

=cut

sub add_script {
    my $self = shift;
    $self->do_command("addScript", @_);
}

=item $sel-E<gt>remove_script($script_tag_id)

Removes a script tag from the Selenium document identified by the givenid. Does nothing if the referenced tag doesn't exist.

=over

$script_tag_id is the id of the script element to remove.

=back

=cut

sub remove_script {
    my $self = shift;
    $self->do_command("removeScript", @_);
}

=item $sel-E<gt>use_xpath_library($library_name)

Allows choice of one of the available libraries.

=over

$library_name is name of the desired library Only the following three can be chosen:   ajaxslt - Google's library   javascript - Cybozu Labs' faster library   default - The default library.  Currently the default library is ajaxslt. If libraryName isn't one of these three, then  no change will be made.

=back

=cut

sub use_xpath_library {
    my $self = shift;
    $self->do_command("useXpathLibrary", @_);
}

=item $sel-E<gt>set_context($context)

Writes a message to the status bar and adds a note to the browser-sidelog.

=over

$context is the message to be sent to the browser

=back

=cut

sub set_context {
    my $self = shift;
    $self->do_command("setContext", @_);
}

=item $sel-E<gt>attach_file($field_locator, $file_locator)

Sets a file input (upload) field to the file listed in fileLocator

=over

$field_locator is an element locator

$file_locator is a URL pointing to the specified file. Before the file  can be set in the input field (fieldLocator), Selenium RC may need to transfer the file    to the local machine before attaching the file in a web page form. This is common in selenium  grid configurations where the RC server driving the browser is not the same  machine that started the test.   Supported Browsers: Firefox ("*chrome") only.

=back

=cut

sub attach_file {
    my $self = shift;
    $self->do_command("attachFile", @_);
}

=item $sel-E<gt>capture_screenshot($filename)

Captures a PNG screenshot to the specified file.

=over

$filename is the absolute path to the file to be written, e.g. "c:\blah\screenshot.png"

=back

=cut

sub capture_screenshot {
    my $self = shift;
    $self->do_command("captureScreenshot", @_);
}

=item $sel-E<gt>capture_screenshot_to_string()

Capture a PNG screenshot.  It then returns the file as a base 64 encoded string.

=over

Returns The base 64 encoded string of the screen shot (PNG file)

=back

=cut

sub capture_screenshot_to_string {
    my $self = shift;
    return $self->get_string("captureScreenshotToString", @_);
}

=item $sel-E<gt>capture_entire_page_screenshot_to_string($kwargs)

Downloads a screenshot of the browser current window canvas to a based 64 encoded PNG file. The I<entire> windows canvas is captured,including parts rendered outside of the current view port.Currently this only works in Mozilla and when running in chrome mode.

=over

$kwargs is A kwargs string that modifies the way the screenshot is captured. Example: "background=#CCFFDD". This may be useful to set for capturing screenshots of less-than-ideal layouts, for example where absolute positioning causes the calculation of the canvas dimension to fail and a black background is exposed  (possibly obscuring black text).

=back

=over

Returns The base 64 encoded string of the page screenshot (PNG file)

=back

=cut

sub capture_entire_page_screenshot_to_string {
    my $self = shift;
    return $self->get_string("captureEntirePageScreenshotToString", @_);
}

=item $sel-E<gt>shut_down_selenium_server()

Kills the running Selenium Server and all browser sessions.  After you run this command, you will no longer be able to sendcommands to the server; you can't remotely start the server once it has been stopped.  Normallyyou should prefer to run the "stop" command, which terminates the current browser session, rather than shutting down the entire server.

=cut

sub shut_down_selenium_server {
    my $self = shift;
    $self->do_command("shutDownSeleniumServer", @_);
}

=item $sel-E<gt>retrieve_last_remote_control_logs()

Retrieve the last messages logged on a specific remote control. Useful for error reports, especiallywhen running multiple remote controls in a distributed environment. The maximum number of log messagesthat can be retrieve is configured on remote control startup.

=over

Returns The last N log messages as a multi-line string.

=back

=cut

sub retrieve_last_remote_control_logs {
    my $self = shift;
    return $self->get_string("retrieveLastRemoteControlLogs", @_);
}

=item $sel-E<gt>key_down_native($keycode)

Simulates a user pressing a key (without releasing it yet) by sending a native operating system keystroke.This function uses the java.awt.Robot class to send a keystroke; this more accurately simulates typinga key on the keyboard.  It does not honor settings from the shiftKeyDown, controlKeyDown, altKeyDown andmetaKeyDown commands, and does not target any particular HTML element.  To send a keystroke to a particularelement, focus on the element first before running this command.

=over

$keycode is an integer keycode number corresponding to a java.awt.event.KeyEvent; note that Java keycodes are NOT the same thing as JavaScript keycodes!

=back

=cut

sub key_down_native {
    my $self = shift;
    $self->do_command("keyDownNative", @_);
}

=item $sel-E<gt>key_up_native($keycode)

Simulates a user releasing a key by sending a native operating system keystroke.This function uses the java.awt.Robot class to send a keystroke; this more accurately simulates typinga key on the keyboard.  It does not honor settings from the shiftKeyDown, controlKeyDown, altKeyDown andmetaKeyDown commands, and does not target any particular HTML element.  To send a keystroke to a particularelement, focus on the element first before running this command.

=over

$keycode is an integer keycode number corresponding to a java.awt.event.KeyEvent; note that Java keycodes are NOT the same thing as JavaScript keycodes!

=back

=cut

sub key_up_native {
    my $self = shift;
    $self->do_command("keyUpNative", @_);
}

=item $sel-E<gt>key_press_native($keycode)

Simulates a user pressing and releasing a key by sending a native operating system keystroke.This function uses the java.awt.Robot class to send a keystroke; this more accurately simulates typinga key on the keyboard.  It does not honor settings from the shiftKeyDown, controlKeyDown, altKeyDown andmetaKeyDown commands, and does not target any particular HTML element.  To send a keystroke to a particularelement, focus on the element first before running this command.

=over

$keycode is an integer keycode number corresponding to a java.awt.event.KeyEvent; note that Java keycodes are NOT the same thing as JavaScript keycodes!

=back

=cut

sub key_press_native {
    my $self = shift;
    $self->do_command("keyPressNative", @_);
}

=item $sel-E<gt>wait_for_text_present($text, $timeout)

Waits until $text is present in the html source

=cut

sub wait_for_text_present {
    my $self = shift;
    $self->do_command("waitForTextPresent", @_);
}

=item $sel-E<gt>wait_for_element_present($locator, $timeout)

Waits until $locator is present

=cut

sub wait_for_element_present {
    my $self = shift;
    $self->do_command("waitForElementPresent", @_);
}


=item * $sel-E<gt>is_location($expected_location)

Verify the location of the current page ends with the expected location.
If an URL querystring is provided, this is checked as well.

=over

$expected_location is the location to match.  

=back

Note: This function is deprecated, use get_location() instead.

=cut

sub is_location {
    my $self = shift;
    warn "is_location() is deprecated, use get_location()\n"
        unless $self->{no_deprecation_msg};
    my $expected_location = shift;
    my $loc = $self->get_string("getLocation");
    return $loc =~ /\Q$expected_location\E$/;
}

=item * $sel-E<gt>get_checked($locator)

Gets whether a toggle-button (checkbox/radio) is checked.  Fails if the specified element doesn't exist or isn't a toggle-button.

=over

$locator is an element locator pointing to a checkbox or radio button.  

=back

Note: This function is deprecated, use is_checked() instead.

=cut

sub get_checked {
    my $self = shift;
    warn "get_checked() is deprecated, use is_checked()\n"
        unless $self->{no_deprecation_msg};
    return $self->get_string("isChecked", @_) ? 'true' : 'false';
}

=item * $sel-E<gt>is_selected($locator, $option_locator)

Verifies that the selected option of a drop-down satisfies the optionSpecifier.

See the select command for more information about option locators.

=over

$locator is an element locator.  
$option_locator is an option locator, typically just an option label (e.g. "John Smith").  

=back

Note: This function is deprecated, use the get_selected_*() methods instead.

=cut

sub is_selected {
    my ($self, $locator, $option_locator) = @_;
    warn "is_selected() is deprecated, use get_selected_*() methods\n"
        unless $self->{no_deprecation_msg};
    $option_locator =~ m/^(?:(.+)=)?(.+)/;
    my $selector = $1 || 'label';
    $selector = 'indexe' if $selector eq 'index';
    my $pattern = $2;
    my $func = "get_selected_${selector}s";
    my @selected = $self->$func($locator);
    return grep { $pattern eq $_ } @selected;
}

=item * $sel-E<gt>get_selected_options($locator)

Gets all option labels for selected options in the specified select or multi-select element.

=over

$locator is an element locator.  

=back

Note: This function is deprecated, use get_selected_labels() instead.

=cut

sub get_selected_options {
    my $self = shift;
    warn "get_selected_options() is deprecated, use get_selected_labels()\n"
        unless $self->{no_deprecation_msg};
    return $self->get_string_array("getSelectedLabels", @_);
}

=item * $sel-E<gt>get_absolute_location()

Gets the absolute URL of the current page.

Note: This function is deprecated, use get_location() instead.

=cut

sub get_absolute_location {
    my $self = shift;
    warn "get_absolute_location() is deprecated, use get_location()\n"
        unless $self->{no_deprecation_msg};
    return $self->get_string("getLocation", @_);
}

=pod

=back

=cut

sub DESTROY {
    my $self = shift;
    $self->stop if $self->{auto_stop};
}

1;

__END__

=head1 SEE ALSO

For more information about Selenium Remote Control, visit the website
at L<http://www.openqa.org/selenium-rc/>.

=head1 BUGS

The Selenium Remote Control JIRA issue tracking system is available
online at L<http://jira.openqa.org/browse/SRC>.

=head1 AUTHOR

Perl driver maintained by Luke Closs <selenium-rc@awesnob.com>

Selenium Remote Control maintained by Dan Fabulich <dfabulich@warpmail.net>

=head1 LICENSE

Copyright (c) 2006 ThoughtWorks, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

