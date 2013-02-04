
use strict                  ;
use warnings FATAL => 'all' ;

use Test                    ;

use ExtUtils::MakeMaker     ;

BEGIN { plan tests => 164 } ;

use XML::Smart              ;


my $DATA = q`<?xml version="1.0" encoding="iso-8859-1"?>
<hosts>
    <server os="linux" type="redhat" version="8.0">
      <address>192.168.0.1</address>
      <address>192.168.0.2</address>
    </server>
    <server os="linux" type="suse" version="7.0">
      <address>192.168.1.10</address>
      <address>192.168.1.20</address>
    </server>
    <server address="192.168.2.100" os="linux" type="conectiva" version="9.0"/>
    <server address="192.168.3.30" os="bsd" type="freebsd" version="9.0"/>
</hosts>
`;

my $XML = new XML::Smart() ;
$XML = new XML::Smart() ;
$XML = new XML::Smart() ;

##if (0) {
#########################
{

    my  $XML = XML::Smart->new( q`
  <html>
    <head>
      <title>Blah blah</title>
    </head>
    <body>
      <form>
        <input id="0"/>        
        <br/>
        <input id="2"/>
        <br/>            
      </form>
    </body>
    <null/>
  </html>
  ` );
  
  my $data = $XML->data( noheader => 1 ) ;
  $data =~ s/\s+/ /gs ;
  
  ok($data , q`<html> <head> <title>Blah blah</title> </head> <body> <form> <input id="0"/> <br/> <input id="2"/> <br/> </form> </body> <null/> </html> `) ;
  
  my @order = $XML->{html}{body}{form}->order ;
  ok(join(" ", @order) eq 'input br input br') ;
  
  $XML->{html}{body}{form}->set_order( qw(br input input br) ) ;
  @order = $XML->{html}{body}{form}->order ;
  ok(join(" ", @order) eq 'br input input br') ;

  $data = $XML->data( noheader => 1 ) ;
  $data =~ s/\s+/ /gs ;
  
  ok($data , q`<html> <head> <title>Blah blah</title> </head> <body> <form> <br/> <input id="0"/> <input id="2"/> <br/> </form> </body> <null/> </html> `) ;

}
#########################
{

  my $XML = XML::Smart->new(q`
<root>
content0
<tag1 arg1="123">
  <sub arg="1">sub_content</sub>
</tag1>
content1
<tag2 arg1="123"/>
content2
</root>
  ` , 'XML::Smart::Parser') ;
  
  my $data = $XML->data(noheader => 1) ;
  
  ok($data , q`<root>
content0
<tag1 arg1="123">
    <sub arg="1">sub_content</sub></tag1>
content1
<tag2 arg1="123"/>
content2
</root>

`) ;
  
  ok( tied $XML->{root}->pointer->{CONTENT} ) ;
  
  my $cont = $XML->{root}->{CONTENT} ;
  
  ok($cont , q`
content0

content1

content2
`) ;
  
  my $cont_ = $XML->{root}->content ;

  ok($cont_ , q`
content0

content1

content2
`) ;
  
  $XML->{root}->content(1,"set1") ;
  
  my @cont = $XML->{root}->content ;
  
  ok($cont[0] , "\ncontent0\n") ;
  ok($cont[1] , "set1") ;
  ok($cont[2] , "\ncontent2\n") ;
  
  $XML->{root}->{CONTENT} = 123 ;
  
  my $cont_2 = $XML->{root}->content ;
  
  skip( ($] >= 5.007 && $] <= 5.008 ? "Skip on $]" : 0 ) , $cont_2 , 123) ;
  
  skip( ($] >= 5.007 && $] <= 5.008 ? "Skip on $]" : 0 ) , !tied $XML->{root}->pointer->{CONTENT} ) ;
  
  ok( !tied $XML->{root}{tag1}{sub}->pointer->{CONTENT} ) ;
  
  my $sub_cont = $XML->{root}{tag1}{sub}->{CONTENT} ;
  
  ok($sub_cont , 'sub_content') ;
  
  $data = $XML->data(noheader => 1) ;
  
  skip( ($] >= 5.007 && $] <= 5.008 ? "Skip on $]" : 0 ) ,
  $data , q`<root>123<tag1 arg1="123">
    <sub arg="1">sub_content</sub>
  </tag1>
  <tag2 arg1="123"/></root>

`) ;
  
}
#########################
{
  
  my $xml = new XML::Smart(q`<?xml version="1.0" encoding="iso-8859-1" ?>
<root>
  <phone>aaa</phone>
  <phone>bbb</phone>
</root>
`) ;

  $xml = $xml->{root} ;

  $xml->{phone}->content('XXX') ;
  
  $xml->{phone}[1]->content('YYY') ;

  $xml->{test}->content('ZZZ') ;

  my $data = $xml->data(noheader => 1) ;

  ok($data , q`<root>
  <phone>XXX</phone>
  <phone>YYY</phone>
  <test>ZZZ</test>
</root>

`) ;  

}
#########################
{

  my $xml = new XML::Smart(q`
<foo>
TEXT1 & more
<if.1>
  aaa
</if.1>
<!-- CMT -->
<elsif.2>
  bbb
</elsif.2>
</foo>  
  `,'html') ;
  
  my $data = $xml->data(noident=>1 , noheader => 1 , wild=>1) ;
  
  ok($data,q`<foo>
TEXT1 &amp; more
<if.1>
  aaa
</if.1>
<!-- CMT -->
<elsif.2>
  bbb
</elsif.2></foo>

`) ;

}
#########################
{

  my $XML = XML::Smart->new('<a>text1<b>foo</b><c>bar</c>text2</a>' , 'XML::Smart::Parser') ;

  my $data = $XML->data(noheader => 1) ;
  $data =~ s/\s//g ;

  ok($data,'<a>text1<b>foo</b><c>bar</c>text2</a>') ;
  
}
#########################
{

  my $XML = XML::Smart->new('<root><foo bar="x"/></root>' , 'XML::Smart::Parser') ;
  my $data = $XML->data(noheader => 1) ;
  
  $data =~ s/\s//gs ;
  ok($data,'<root><foobar="x"/></root>') ;

}
#########################
{
  
  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
  
  my $data = $XML->data(nometagen => 1) ;
  $data =~ s/\s//gs ;
  
  my $data_org = $DATA ;
  $data_org =~ s/\s//gs ;
  
  ok($data,$data_org) ;
    
}
#########################
{

  my $XML = XML::Smart->new('<root><foo bar="x"/></root>' , 'XML::Smart::HTMLParser') ;
  my $data = $XML->data(noheader => 1) ;
  $data =~ s/\s//gs ;
  ok($data,'<root><foobar="x"/></root>') ;
  
  $XML = XML::Smart->new(q`
  <html><title>TITLE</title>
  <body bgcolor='#000000'>
    <foo1 baz="y1=name\" bar1=x1 > end" w=q>
    <foo2 bar2="" arg0 x=y>FOO2-DATA</foo2>
    <foo3 bar3=x3>
    <foo4 url=http://www.com/dir/file.x?query=value&x=y>
  </body>
  </html>
  ` , 'HTML') ;
  
  $data = $XML->data(noheader => 1 , nospace => 1 ) ;
  ok($data,q`<html><title>TITLE</title><body bgcolor="#000000"><foo1 baz='y1=name\" bar1=x1 &gt; end' w="q"/><foo2 bar2="" arg0="" x="y">FOO2-DATA</foo2><foo3 bar3="x3"/><foo4 url="http://www.com/dir/file.x?query=value&amp;x=y"/></body></html>`) ;

  $XML = XML::Smart->new(q`
  <html><title>TITLE</title>
  <body bgcolor='#000000'>
    <foo1 bar1=x1>
    <SCRIPT LANGUAGE="JavaScript"><!--
    function stopError() { return true; }
    window.onerror = stopError;
    document.writeln("some >> written!");
    --></SCRIPT>
    <foo2 bar2=x2>
  </body></html>
  ` , 'HTML') ;
  
  $data = $XML->data(noheader => 1 , nospace => 1) ;
  $data =~ s/\s//gs ;
  
  ok($data,q`<html><title>TITLE</title><bodybgcolor="#000000"><foo1bar1="x1"/><SCRIPTLANGUAGE="JavaScript"><!--functionstopError(){returntrue;}window.onerror=stopError;document.writeln("some>>written!");--></SCRIPT><foo2bar2="x2"/></body></html>`);

}
#########################
{
  my $XML = XML::Smart->new(q`
  <root>
    <foo name='x' *>
      <.sub1 arg="1" x=1 />
      <.sub2 arg="2"/>
      <bar size="100,50" +>
      content
      </bar>
    </foo>
  </root>
  ` , 'XML::Smart::HTMLParser') ;
  
  my $data = $XML->data(noheader => 1 , wild => 1) ;
  
  ok($data , q`<root>
  <foo name="x" *>
    <.sub1 arg="1" x="1"/>
    <.sub2 arg="2"/>
    <bar size="100,50" +>
      content
      </bar>
  </foo>
</root>

`);

}
#########################
{
  my $XML0 = XML::Smart->new(q`<root><foo1 name='x'/></root>` , 'XML::Smart::Parser') ;
  my $XML1 = XML::Smart->new(q`<root><foo2 name='y'/></root>` , 'XML::Smart::Parser') ;
  
  my $XML = XML::Smart->new() ;
  
  $XML->{sub}{sub2} = $XML0->tree ;
  push(@{$XML->{sub}{sub2}} , $XML1->tree ) ;
  
  my $data = $XML->data(noheader => 1) ;
  
  $data =~ s/\s//gs ;
  ok($data,'<sub><sub2><root><foo1name="x"/></root></sub2><sub2><root><foo2name="y"/></root></sub2></sub>') ;

}
#########################
{
  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
  $XML = $XML->{hosts} ;
  
  my $addr = $XML->{server}[0]{address} ;
  ok($addr,'192.168.0.1') ;
  
  my $addr0 = $XML->{server}[0]{address}[0] ;
  ok($addr,$addr0);
  
  my $addr1 = $XML->{server}{address}[1] ;
  ok($addr1,'192.168.0.2') ;
  
  my $addr01 = $XML->{server}[0]{address}[1] ;
  ok($addr1,$addr01);
  
  my @addrs = @{$XML->{server}{address}} ;
  
  ok($addrs[0],$addr0);
  ok($addrs[1],$addr1);
  
  @addrs = @{$XML->{server}[0]{address}} ;
  
  ok($addrs[0],$addr0);
  ok($addrs[1],$addr1);
}
#########################
{

  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
  $XML = $XML->{hosts} ;
  
  my $addr = $XML->{'server'}('type','eq','suse'){'address'} ;
  ok($addr,'192.168.1.10') ;
  
  my $addr0 = $XML->{'server'}('type','eq','suse'){'address'}[0] ;
  ok($addr,$addr0) ;
  
  my $addr1 = $XML->{'server'}('type','eq','suse'){'address'}[1] ;
  ok($addr1,'192.168.1.20') ;
  
  my $type = $XML->{'server'}('version','>=','9'){'type'} ;
  ok($type,'conectiva') ;
  
  $addr = $XML->{'server'}('version','>=','9'){'address'} ;
  ok($addr,'192.168.2.100') ;
  
  $addr0 = $XML->{'server'}('version','>=','9'){'address'}[0] ;
  ok($addr0,$addr) ;
    
}
#########################
{

  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
  $XML = $XML->{hosts} ;

  my $newsrv = {
  os => 'Linux' ,
  type => 'mandrake' ,
  version => 8.9 ,
  address => '192.168.3.201' ,
  } ;

  push(@{$XML->{server}} , $newsrv) ;
  
  my $addr0 = $XML->{'server'}('type','eq','mandrake'){'address'}[0] ;
  ok($addr0,'192.168.3.201') ;
  
  $XML->{'server'}('type','eq','mandrake'){'address'}[1] = '192.168.3.202' ;

  my $addr1 = $XML->{'server'}('type','eq','mandrake'){'address'}[1] ;
  ok($addr1,'192.168.3.202') ;
  
  push(@{$XML->{'server'}('type','eq','conectiva'){'address'}} , '192.168.2.101') ;

  $addr1 = $XML->{'server'}('type','eq','conectiva'){'address'}[1] ;
  ok($addr1,'192.168.2.101') ;
  
  $addr1 = $XML->{'server'}[2]{'address'}[1] ;
  ok($addr1,'192.168.2.101') ;
  
}
#########################
{
  
  my $XML = XML::Smart->new(q`
  <users>
    <joe name="Joe X" email="joe@mail.com"/>
    <jonh name="JoH Y" email="jonh@mail.com"/>
    <jack name="Jack Z" email="jack@mail.com"/>
  </users>
  ` , 'XML::Smart::Parser') ;
  
  my @users = $XML->{users}('email','=~','^jo') ;
  
  ok( $users[0]->{name} , 'Joe X') ;
  ok( $users[1]->{name} , 'JoH Y') ;
  
}
#########################
{
  my $XML = XML::Smart->new() ;
  
  $XML->{server} = {
  os => 'Linux' ,
  type => 'mandrake' ,
  version => 8.9 ,
  address => '192.168.3.201' ,
  } ;

  $XML->{server}{address}[1] = '192.168.3.202' ;
  
  my $data = $XML->data(noheader => 1) ;
  $data =~ s/\s//gs ;
    
  my $dataok = q`<serveros="Linux"type="mandrake"version="8.9"><address>192.168.3.201</address><address>192.168.3.202</address></server>`;
  ok($data,$dataok) ;

}
#########################
{

  my $XML = XML::Smart->new('<foo port="80">ct<i>a</i><i>b</i></foo>' , 'XML::Smart::Parser') ;
  my $data = $XML->data(noheader => 1) ;
  $data =~ s/\s//gs ;
  
  my $dataok = qq`<fooport="80">ct<i>a</i><i>b</i></foo>` ;
  
  ok($data,$dataok) ;

}
#########################
{

  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
  
  $XML->{'hosts'}{'server'}('type','eq','conectiva'){'address'}[1] = '' ;
  
  my $data = $XML->data(
  noident => 1 ,
  nospace => 1 ,
  lowtag => 1 ,
  upertag => 1 ,
  uperarg => 1 ,
  noheader => 1 ,
  ) ;
  
  $data =~ s/\s//gs ;
  
  my $dataok = q`<HOSTS><SERVEROS="linux"TYPE="redhat"VERSION="8.0"><ADDRESS>192.168.0.1</ADDRESS><ADDRESS>192.168.0.2</ADDRESS></SERVER><SERVEROS="linux"TYPE="suse"VERSION="7.0"><ADDRESS>192.168.1.10</ADDRESS><ADDRESS>192.168.1.20</ADDRESS></SERVER><SERVERADDRESS="192.168.2.100"OS="linux"TYPE="conectiva"VERSION="9.0"/><SERVERADDRESS="192.168.3.30"OS="bsd"TYPE="freebsd"VERSION="9.0"/></HOSTS>`;
  ok($data,$dataok) ;
  
}
#########################
{

  my $XML = XML::Smart->new('' , 'XML::Smart::Parser') ;
  
  $XML->{data} = 'aaa' ;
  $XML->{var } = 10    ;
  
  $XML->{addr} = [qw(1 2 3)] ;
  
  my $data = $XML->data(length => 1 , nometagen => 1 ) ;
  $data =~ s/\s//gs ;
  
  my $dataok = q`<?xmlversion="1.0"encoding="iso-8859-1"length="88"?><rootdata="aaa"var="10"><addr>1</addr><addr>2</addr><addr>3</addr></root>`;

  ok($data,$dataok) ;
}
#########################
{

  my $XML = XML::Smart->new('' , 'XML::Smart::Parser') ;
  
  $XML->{hosts}{server} = {
  os => 'lx'  ,
  type => 'red'  ,
  ver => 123 ,
  } ;
  
  my $data = $XML->data(noheader => 1) ;
  $data =~ s/\s//gs ;
  
  my $dataok = q`<hosts><serveros="lx"type="red"ver="123"/></hosts>`;
  
  ok($data,$dataok) ;
                       
  $XML->{hosts}[1]{server}[0] = {
  os => 'LX'  ,
  type => 'red'  ,
  ver => 123 ,
  } ;
  
  $data = $XML->data(noheader => 1) ;
  $data =~ s/\s//gs ;
  
  $dataok = q`<root><hosts><serveros="lx"type="red"ver="123"/></hosts><hosts><serveros="LX"type="red"ver="123"/></hosts></root>`;
  
  ok($data,$dataok) ;

}
#########################
{

  my $XML = XML::Smart->new('' , 'XML::Smart::Parser') ;
                          
  $XML->{hosts}[1]{server}[0] = {
  os => 'LX'  ,
  type => 'red'  ,
  ver => 123 ,
  } ;
  
  my $data = $XML->data(noheader => 1) ;
  $data =~ s/\s//gs ;
  
  my $dataok = q`<hosts><serveros="LX"type="red"ver="123"/></hosts>`;
  
  ok($data,$dataok) ;

}
#########################
{

  my $XML = XML::Smart->new('' , 'XML::Smart::Parser') ;
                          
  my $srv = {
  os => 'lx'  ,
  type => 'red'  ,
  ver => 123 ,
  } ;

  push( @{$XML->{hosts}} , {XXXXXX => 1}) ;
  
  unshift( @{$XML->{hosts}}  , $srv) ;
  
  push( @{$XML->{hosts}{more}}  , {YYYY => 1}) ;
  
  my $data = $XML->data(noheader => 1) ;
  $data =~ s/\s//gs ;
  
  my $dataok = q`<root><hostsos="lx"type="red"ver="123"><moreYYYY="1"/></hosts><hostsXXXXXX="1"/></root>` ;
  
  ok($data,$dataok) ;

}
#########################
{

  my $XML = XML::Smart->new('' , 'XML::Smart::Parser') ;
  
  $XML->{hosts}{server} = [
  { os => 'lx' , type => 'a' , ver => '1' ,} ,
  { os => 'lx ', type => 'b' , ver => '2' ,} ,
  ];
  
  ok( $XML->{hosts}{server}{type} , 'a') ;
  
  my $srv0 = shift( @{$XML->{hosts}{server}} ) ;
  ok( $$srv0{type} , 'a') ;
  
  ok( $XML->{hosts}{server}{type} , 'b') ;
  ok( $XML->{hosts}{server}{type}[0] , 'b') ;
  ok( $XML->{hosts}{server}[0]{type}[0] , 'b') ;
  ok( $XML->{hosts}[0]{server}[0]{type}[0] , 'b') ;
  
  my $srv1 = pop( @{$XML->{hosts}{server}} ) ;
  ok( $$srv1{type} , 'b') ;
  
  my $data = $XML->data(noheader => 1 , nospace=>1) ;
  ok($data , '<hosts></hosts>') ;

}
#########################
{

  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;

  my @types = $XML->{hosts}{server}('[@]','type') ;
  ok("@types" , 'redhat suse conectiva freebsd') ;

  @types = $XML->{hosts}{server}{type}('<@') ;
  ok("@types" , 'redhat suse conectiva freebsd') ;
  
}
#########################
{

  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;

  my @srvs = $XML->{hosts}{server}('os','eq','linux') ;
  
  my @types ;
  foreach my $srvs_i ( @srvs ) { push(@types , $srvs_i->{type}) ;}
  ok("@types" , 'redhat suse conectiva') ;

  @srvs = $XML->{hosts}{server}(['os','eq','linux'],['os','eq','bsd']) ;
  @types = () ;
  foreach my $srvs_i ( @srvs ) { push(@types , $srvs_i->{type}) ;}
  ok("@types" , 'redhat suse conectiva freebsd') ;
  
}
#########################
{

  my $wild = pack("C", 127 ) ;

  my $data = qq`<?xml version="1.0" encoding="iso-8859-1"?><code>$wild</code>`;

  my $XML = XML::Smart->new($data , 'XML::Smart::Parser') ;

  ok($XML->{code} , $wild) ;
  $data = $XML->data() ;
  
  $XML = XML::Smart->new($data , 'XML::Smart::Parser') ;

  ok($XML->{code} , $wild) ;
  
  my $data2 = $XML->data() ;
  ok($data , $data2) ;

}
#########################
{

  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
  
  my $addr1 = $XML->{hosts}{server}{address} ;
  
  my $XML2 = $XML->cut_root ;
  my $addr2 = $XML2->{server}{address} ;

  ok($addr1,$addr2) ;

}
#########################
{

  my $data = q`
  <root>
    <foo bar="x"> My Company &amp; Name + x &gt;&gt; plus &quot; + &apos;...</foo>
  </root>
  `;

  my $XML = XML::Smart->new($data , 'XML::Smart::Parser') ;
  
  ok($XML->{root}{foo} , q` My Company & Name + x >> plus " + '...`) ;
  
  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<root><foo bar="x"> My Company &amp; Name + x &gt;&gt; plus " + '...</foo></root>`) ;

}
#########################
{

  my $XML = XML::Smart->new(q`
  <root>
    <foo arg1="x" arg2="y">
      <bar arg='z'>cont</bar>
    </foo>
  </root>
  ` , 'XML::Smart::Parser') ;
  
  my @nodes = $XML->{root}{foo}->nodes ;
  
  ok($nodes[0]->{arg},'z');

  
  @nodes = $XML->{root}{foo}->nodes_keys ;
  ok("@nodes",'bar');

  ok($XML->{root}{foo}{bar}->is_node) ;
  
  my @keys = $XML->{root}{foo}('@keys') ;
  ok("@keys",'arg1 arg2 bar');  

}
#########################
{

  my $data = qq`
  <root>
    <item arg1="x">
      <data><![CDATA[some CDATA code <non> <parsed> <tag> end]]></data>
    </item>
  </root>
  `;

  my $XML = XML::Smart->new($data , 'XML::Smart::Parser') ;
  
  ok( $XML->{root}{item}{data} , q`some CDATA code <non> <parsed> <tag> end`) ;
  
}
#########################
{

  my $XML = XML::Smart->new() ;
  
  $XML->{menu}{option}[0] = {
  name => "Help" ,
  level => {from => 1 , to => 99} ,
  } ;

  $XML->{menu}{option}[0]{sub}{option}[0] = {
  name => "Busca" ,
  level => {from => 1 , to => 99} ,
  } ;

  my $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  
  ok($data , q`<menu><option name="Help"><level from="1" to="99"/><sub><option name="Busca"><level from="1" to="99"/></option></sub></option></menu>`) ;

}
#########################
{
  
  my $XML = XML::Smart->new() ;
  
  $XML->{menu}{arg1} = 123 ;
  $XML->{menu}{arg2} = 456 ;
  
  $XML->{menu}{arg2}{subarg} = 999 ;
  
  ok($XML->{menu}{arg1} , 123) ;
  ok($XML->{menu}{arg2} , 456) ;
  ok($XML->{menu}{arg2}{subarg} , 999) ;

  my $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<menu arg1="123"><arg2 subarg="999">456</arg2></menu>`) ;

}
#########################
{
  
  my $XML = XML::Smart->new() ;
  
  $XML->{menu}{arg1} = [1,2,3] ;
  $XML->{menu}{arg2} = 4 ;
  
  my @arg1 = $XML->{menu}{arg1}('@') ;
  ok($#arg1 , 2) ;
  
  my @arg2 = $XML->{menu}{arg2}('@') ;
  ok($#arg2 , 0) ;
  
  my @arg3 = $XML->{menu}{arg3}('@') ;  
  ok($#arg3 , -1) ;  

}
#########################
{
  
  my $XML = XML::Smart->new() ;
  
  $XML->{menu}{arg2} = 456 ;
  $XML->{menu}{arg1} = 123 ;
  
  my $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<menu arg2="456" arg1="123"/>`) ;

  $XML->{menu}{arg2}->set_node ;
  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<menu arg1="123"><arg2>456</arg2></menu>`) ;

  $XML->{menu}{arg2}->set_node(0) ;
  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<menu arg2="456" arg1="123"/>`) ;
  
  $XML->{menu}->set_order('arg1' , 'arg2') ;
  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<menu arg1="123" arg2="456"/>`) ;
  
  delete $XML->{menu}{arg2}[0] ;

  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<menu arg1="123"/>`) ;

}
#########################
{


  my $XML = XML::Smart->new() ;
  $XML->{root}{foo} = "bla bla bla";

  $XML->{root}{foo}->set_node(1) ;

  ok( $XML->tree->{root}{'/nodes'}{foo} , '1' ) ;
  ok( $XML->tree->{root}{foo}{CONTENT} , "bla bla bla" ) ;  
  

  ok( ref $XML->tree->{ root }{ foo }, 'HASH' ) ;

  $XML->{root}{foo}->set_node(0) ;

  ok( ref $XML->tree->{ root }{ foo }, '' ) ;
  ok( !exists $XML->tree->{root}{'/nodes'}{foo} ) ;
  
  $XML->{root}{foo}->set_cdata(1) ;
  
  ok( $XML->tree->{root}{'/nodes'}{foo} , 'cdata,1,' )   ;
  ok( $XML->tree->{root}{foo}{CONTENT} , "bla bla bla" ) ;  
  
  $XML->{root}{foo}->set_node(1) ;
  
  ok( $XML->tree->{root}{'/nodes'}{foo} , 'cdata,1,1' ) ;
  ok( $XML->tree->{root}{foo}{CONTENT} , "bla bla bla" ) ;  
  
  $XML->{root}{foo}->set_binary(1) ;
  
  ok( $XML->tree->{root}{'/nodes'}{foo} , 'binary,1,1' ) ;
  ok( $XML->tree->{root}{foo}{CONTENT} , "bla bla bla" ) ;  
  
  $XML->{root}{foo}->set_binary(0) ;

  ok( $XML->tree->{root}{'/nodes'}{foo} , 'binary,0,1' ) ;
  ok( $XML->tree->{root}{foo}{CONTENT} , "bla bla bla" ) ;  
  
  $XML->{root}{foo}->set_auto_node ;
  
  ok( $XML->tree->{root}{'/nodes'}{foo} , 1 ) ;
  ok( $XML->tree->{root}{foo}{CONTENT} , "bla bla bla" ) ;  
  
  $XML->{root}{foo}->set_cdata(0) ;
  
  ok( $XML->tree->{root}{'/nodes'}{foo} , 'cdata,0,1' ) ;
  ok( $XML->tree->{root}{foo}{CONTENT} , "bla bla bla" ) ;
  
  $XML->{root}{foo}->set_binary(0) ;
  
  ok( $XML->tree->{root}{'/nodes'}{foo} , 'binary,0,1' ) ;
  ok( $XML->tree->{root}{foo}{CONTENT} , "bla bla bla" ) ;

  ok( ref( $XML->tree->{root}{foo} ), 'HASH' ) ; 
  $XML->{root}{foo}->set_auto ;

  ok( ref( $XML->tree->{root}{foo} ), '' ) ; 
  ok( !exists $XML->tree->{root}{'/nodes'}{foo} ) ;

}
#########################
{

  my $XML = new XML::Smart ;
  $XML->{root}{foo} = "bla bla bla <tag> bla bla";

  my $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root><foo><![CDATA[bla bla bla <tag> bla bla]]></foo></root>') ;

  $XML->{root}{foo}->set_cdata(0) ;
  
  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root><foo>bla bla bla &lt;tag&gt; bla bla</foo></root>') ;
  
  $XML->{root}{foo}->set_binary(1) ;
  
  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root><foo dt:dt="binary.base64">YmxhIGJsYSBibGEgPHRhZz4gYmxhIGJsYQ==</foo></root>') ;

}
#########################
{

  my $XML = new XML::Smart ;
  $XML->{root}{foo} = "<h1>test \x03</h1>";

  my $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root><foo dt:dt="binary.base64">PGgxPnRlc3QgAzwvaDE+</foo></root>') ;

  $XML->{root}{foo}->set_binary(0) ;
  
  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , "<root><foo>&lt;h1&gt;test \x03\&lt;/h1&gt;</foo></root>") ;
  
  $XML->{root}{foo}->set_binary(1) ;
  
  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root><foo dt:dt="binary.base64">PGgxPnRlc3QgAzwvaDE+</foo></root>') ;

}
#########################
{

  my $XML = new XML::Smart ;
  $XML->{root}{foo} = "simple";

  my $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root foo="simple"/>') ;
  
  $XML->{root}{foo}->set_cdata(1) ;

  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root><foo><![CDATA[simple]]></foo></root>') ;
  
}
#########################
{

  my $XML = new XML::Smart ;
  $XML->{root}{foo} = "<words>foo bar baz</words>";

  my $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root><foo><![CDATA[<words>foo bar baz</words>]]></foo></root>') ;
  
  $XML->{root}{foo}->set_cdata(0) ;

  $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , '<root><foo>&lt;words&gt;foo bar baz&lt;/words&gt;</foo></root>') ;  

}
#########################
{
  
  my $XML = XML::Smart->new(q`<?xml version="1.0"?>
  <root>
    <entry><b>here's</b> a <i>test</i></entry>
  </root>
  `, 'XML::Parser');

  my $data = $XML->data(nospace => 1 , noheader => 1 ) ;
  ok($data , "<root><entry><b>here's</b> a <i>test</i></entry></root>") ;  

}
#########################
{

  my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
  $XML = $XML->{hosts} ;
  
  my $addr = $XML->{'server'}('type','eq','suse'){'address'} ;
  
  ok($addr->path , '/hosts/server[1]/address') ;
  
  my $addr0 = $XML->{'server'}('type','eq','suse'){'address'}[0] ;
  
  ok($addr0->path , '/hosts/server[1]/address[0]') ;
  ok($addr0->path_as_xpath , '/hosts/server[2]/address') ;
  
  my $addr1 = $XML->{'server'}('type','eq','suse'){'address'}[1] ;
  
  my $type = $XML->{'server'}('version','>=','9'){'type'} ;

  ok($type->path , '/hosts/server[2]/type') ;
  
  $addr = $XML->{'server'}('version','>=','9'){'address'} ;

  ok($addr->path , '/hosts/server[2]/address') ;
  
  $addr0 = $XML->{'server'}('version','>=','9'){'address'}[0] ;

  ok($addr0->path , '/hosts/server[2]/address[0]') ;
  ok($addr0->path_as_xpath , '/hosts/server[3]/@address') ;
  
  $type = $XML->{'server'}('version','>=','9'){'type'} ;
  
  ok($type->path , '/hosts/server[2]/type') ;
  ok($type->path_as_xpath , '/hosts/server[3]/@type') ;
    
}
#########################
{

  my $XML = new XML::Smart(q`
  <root>
    <output name='123'>
      <frames format='a'/>
      <frames format='b'/>
    </output>
    <output>
      <name>456</name>
      <frames format='c'/>
      <frames format='d'/>
    </output>
  </root>
  `,'smart');
  
  $XML = $XML->cut_root ;
  
  my @frames_123 = @{ $XML->{'output'}('name','eq',123){'frames'} } ;
  my @formats_123 = map { $_->{'format'} } @frames_123 ;
  
  my @frames_456 = @{ $XML->{'output'}('name','eq',456){'frames'} } ;
  my @formats_456 = map { $_->{format} } @frames_456 ;

  ok( join(";", @formats_123) , 'a;b' ) ;
  ok( join(";", @formats_456) , 'c;d' ) ;

}
#########################
{
  
  my $html = q`
  <html>
  <p id="$s->{supply}->shift">foo</p>
   </html>
  `;
  
  my @tag ;

  my $p = XML::Smart::HTMLParser->new(
  Start => sub { shift; push(@tag , @_) ;},
  Char => sub {},
  End => sub {},
  );

  $p->parse($html) ;

  ok($tag[-1] , '$s->{supply}->shift') ;  

}
#########################
{
  
  my $xml = new XML::Smart(q`<?xml version="1.0" encoding="UTF-8"?>
<doc type="test">
  <data>test 1</data>
  <data>test 2</data>
  <data>test 3</data>
  <file>file 1</file>
</doc>
  `);

  $xml->{doc}{port}[0] = 0;
  $xml->{doc}{port}[1] = 1;
  $xml->{doc}{port}[2] = 2;
  $xml->{doc}{port}[3] = 3;
  
  my $data = $xml->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<doc type="test"><data>test 1</data><data>test 2</data><data>test 3</data><file>file 1</file><port>0</port><port>1</port><port>2</port><port>3</port></doc>`) ;
  
  pop @{$xml->{doc}{'/order'}} ;

  $data = $xml->data(nospace => 1 , noheader => 1 ) ;
  ok($data , q`<doc type="test"><data>test 1</data><data>test 2</data><data>test 3</data><file>file 1</file><port>0</port><port>1</port><port>2</port><port>3</port></doc>`) ;

}
#########################
{
  eval(q`use XML::XPath`) ;
  if ( !$@ ) {
    my $XML = XML::Smart->new($DATA , 'XML::Smart::Parser') ;
    
    my $xp1 = $XML->XPath ;
    my $xp2 = $XML->XPath ;
    ok($xp1,$xp2) ;
    
    $xp1 = $XML->XPath ;
    $XML->{hosts}{tmp} = 123 ;
    $xp2 = $XML->XPath ;
    
   ## Test cache of the XPath object:
    ok(1) if $xp1 != $xp2 ;
  
    delete $XML->{hosts}{tmp} ;
  
    my $data = $XML->XPath->findnodes_as_string('/') ;
    
    ok($data , q`<hosts><server os="linux" type="redhat" version="8.0"><address>192.168.0.1</address><address>192.168.0.2</address></server><server os="linux" type="suse" version="7.0"><address>192.168.1.10</address><address>192.168.1.20</address></server><server address="192.168.2.100" os="linux" type="conectiva" version="9.0" /><server address="192.168.3.30" os="bsd" type="freebsd" version="9.0" /></hosts>`) ;
  }
}
#########################
{

  use XML::Smart::DTD ;

  my $dtd = XML::Smart::DTD->new(q`
<!DOCTYPE curso [
<!ELEMENT curso (objetivo|descricao , curriculo? , aluno+ , professor+)>
<!ATTLIST curso
          centro  CDATA #REQUIRED
          nome    (a|b|c|"a simple | test",d) #REQUIRED "a"
          age    CDATA
>
<!ELEMENT objetivo (#PCDATA)>
<!ELEMENT curriculo (disciplina+)>
<!ELEMENT disciplina (requisito , professor+)>
<!ATTLIST disciplina
          codigo     CDATA #REQUIRED
          ementa     CDATA #REQUIRED
>
<!ELEMENT descricao (#PCDATA)>
<!ELEMENT requisito (#PCDATA)>
<!ELEMENT professor (#PCDATA)>
<!ELEMENT br EMPTY>
]>
  `) ;
  
  ok( $dtd->elem_exists('curso') ) ;
  ok( $dtd->elem_exists('objetivo') ) ;
  ok( $dtd->elem_exists('curriculo') ) ;
  ok( $dtd->elem_exists('disciplina') ) ;
  ok( $dtd->elem_exists('descricao') ) ;
  ok( $dtd->elem_exists('requisito') ) ;  
  ok( $dtd->elem_exists('professor') ) ;  
  ok( $dtd->elem_exists('br') ) ;  
  
  ok( $dtd->is_elem_req('requisito') ) ;
  ok( $dtd->is_elem_uniq('requisito') ) ;
  
  ok( $dtd->is_elem_opt('curriculo') ) ;
  ok( !$dtd->is_elem_req('curriculo') ) ;
  
  ok( $dtd->is_elem_multi('professor') ) ;
  
  ok( $dtd->is_elem_pcdata('professor') ) ;
  ok( $dtd->is_elem_empty('br') ) ;

  ok( $dtd->attr_exists('curso','centro') ) ;
  ok( $dtd->attr_exists('curso','nome') ) ;
  
  ok( $dtd->attr_exists('curso','centro','nome') ) ;
  
  ok( !$dtd->attr_exists('curso','centro','nomes') ) ;
  
  my @attrs = $dtd->get_attrs('curso') ;
  ok( join(" ",@attrs) , 'centro nome age') ;
  
  @attrs = $dtd->get_attrs_req('curso') ;
  ok( join(" ",@attrs) , 'centro nome') ;
  
}
#########################
{

  my $xml = XML::Smart->new()->{cds} ;
  
  $xml->{album}[0] = {
  title => 'foo' ,
  artist => 'the foos' ,
  tracks => 8 ,
  } ;
  
  $xml->{album}[1] = {
  title => 'bar' ,
  artist => 'the barss' ,
  tracks => [qw(6 7)] ,
  time => [qw(60 70)] ,
  type => 'b' ,
  } ;
  
  $xml->{album}[2] = {
  title => 'baz' ,
  artist => undef ,
  tracks => 10 ,
  type => '' ,
  br => 123 ,
  } ;
  
  $xml->{creator} = 'Joe' ;
  $xml->{date} = '2000-01-01' ;
  $xml->{type} = 'a' ;
  
  $xml->{album}[0]{title}->set_node(1);
  
  ok( $xml->data( noheader=>1 , nospace=>1) , q`<cds creator="Joe" date="2000-01-01" type="a"><album artist="the foos" tracks="8"><title>foo</title></album><album artist="the barss" title="bar" type="b"><time>60</time><time>70</time><tracks>6</tracks><tracks>7</tracks></album><album artist="" br="123" title="baz" tracks="10" type=""/></cds>`) ;
  
  $xml->apply_dtd(q`
<!DOCTYPE cds [
<!ELEMENT cds (album+)>
<!ATTLIST cds
          creator  CDATA
          date     CDATA #REQUIRED
          type     (a|b|c) #REQUIRED "a"
>
<!ELEMENT album (artist , tracks+ , time? , auto , br?)>
<!ATTLIST album
          title     CDATA #REQUIRED
          type     (a|b|c) #REQUIRED "a"
>
<!ELEMENT artist (#PCDATA)>
<!ELEMENT tracks (#PCDATA)>
<!ELEMENT auto (#PCDATA)>
<!ELEMENT br EMPTY>
]>
  `);
  
  ok( $xml->data(noheader=>1 , nospace=>1) , q`<!DOCTYPE cds [
<!ELEMENT cds (album+)>
<!ELEMENT album (artist , tracks+ , time? , auto , br?)>
<!ELEMENT artist (#PCDATA)>
<!ELEMENT tracks (#PCDATA)>
<!ELEMENT auto (#PCDATA)>
<!ELEMENT br EMPTY>
<!ATTLIST cds
          creator  CDATA
          date     CDATA #REQUIRED
          type     (a|b|c) #REQUIRED "a"
>
<!ATTLIST album
          title     CDATA #REQUIRED
          type     (a|b|c) #REQUIRED "a"
>
]><cds creator="Joe" date="2000-01-01" type="a"><album title="foo" type="a"><artist>the foos</artist><tracks>8</tracks><auto></auto></album><album title="bar" type="b"><artist>the barss</artist><tracks>6</tracks><tracks>7</tracks><time>60</time><auto></auto></album><album title="baz" type="a"><artist></artist><tracks>10</tracks><auto></auto><br/></album></cds>` );

}
#########################
{
  
  my $xml = XML::Smart->new;
  $xml->{customer}{phone} = "555-1234";
  $xml->{customer}{phone}{type} = "home";
  
  $xml->apply_dtd(q`
  <?xml version="1.0" ?>
  <!DOCTYPE customer [
  <!ELEMENT customer (type?,phone+)>
  <!ELEMENT phone (#PCDATA)>
  <!ATTLIST phone type CDATA #REQUIRED>
  <!ELEMENT type (#PCDATA)>
  ]>
  `);
  
  ok( $xml->data(noheader=>1 , nospace=>1 , nodtd=>1) , q`<customer><phone type="home">555-1234</phone></customer>` );

}
#########################


1 ;



