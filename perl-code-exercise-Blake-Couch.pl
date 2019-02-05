use Scalar::Util qw(reftype);

my $output_type = 'HTML';
#   $output_type = 'JS';
my $object = [0, 1, {"a" => "ah", "b" => "bee"}, [3,4,5], "string"];
#   $object = "it's a scalar";
#   $object = {"a" => "ah", "b" => "bee"};
   
my $result = parse_it($object, $output_type);

print $result;

exit;

sub parse_it {
    my ($object,$output_type) = @_;
    unless (ref($object)) {  # it's a scalar
        return($object);
    }
    
    my $argtype = reftype($object);
    my $ret = '';
    
    if ($argtype eq "ARRAY") {
        $ret .= parse_array($object,$output_type,0);
    } elsif ($argtype eq "HASH") {
        $ret .= parse_hash($object,$output_type,0);
    } else {
        return("invalid parameter type");
    }
    
    return($ret);
}

sub parse_array {
    my ($object,$output_type,$iCount) = @_;
    my @arr = @$object;
    my $indents = "\t" x $iCount;
    
    my $ret = ($output_type eq "HTML" ? "\n$indents<OL>\n" : $output_type eq "JS" ? "[" : "");
    $iCount++;
    $indents = "\t" x $iCount;
    
    for my $val (@arr) {
        my $optNewLine = '';
        $ret .= ($output_type eq "HTML" ? "$indents<LI>" : "");
        if(ref($val)) {
            $iCount++;
            if(reftype($val) eq "ARRAY") {
                $ret .= parse_array($val, $output_type, $iCount);;
            } elsif(reftype($val) eq "HASH") {
                $ret .= parse_hash($val, $output_type, $iCount);;
            }
            $optNewLine = "\n$indents";
            $iCount--;
        } else {
            $ret .= ($output_type eq "JS" ? '"' : "") . $val . ($output_type eq "JS" ? '"' : "");
        }
        $ret .= ($output_type eq "HTML" ? "$optNewLine</LI>\n" : $output_type eq "JS" ? ', ' : "");
    }
    $ret =~ s/, $//;
    
    $iCount--;
    $indents = "\t" x $iCount;
    
    $ret .= ($output_type eq "HTML" ? "$indents</OL>" : $output_type eq "JS" ? ']' : "");
    return($ret);
}

sub parse_hash {
    my ($object,$output_type,$iCount) = @_;
    my %h = %$object;
    my $indents = "\t" x $iCount;
    
    my $ret = ($output_type eq "HTML" ? "\n$indents<DL>\n" : $output_type eq "JS" ? "{" : "");
    
    $iCount++;
    $indents = "\t" x $iCount;

    for my $key (keys %h) {
        $ret .= ($output_type eq "HTML" ? "$indents<DT>" : $output_type eq "JS" ? '"' : "");
        $ret .= $key;
        $ret .= ($output_type eq "HTML" ? "</DT>\n" : $output_type eq "JS" ? '": ' : "");
        $ret .= ($output_type eq "HTML" ? "$indents<DD>" : $output_type eq "JS" ? '"' : "");
        if(ref($h{$key})) {
            if(reftype($h{$key}) eq "ARRAY") {
                $ret .= parse_array($h{$key}, $output_type, $iCount);
            } elsif(reftype($h{$key}) eq "HASH") {
                $ret .= parse_hash($h{$key}, $output_type, $iCount);
            }
        } else {
            $ret .= $h{$key} . ($output_type eq "JS" ? '"' : '');
        }
        $ret .= ($output_type eq "HTML" ? "</DD>\n" : $output_type eq "JS" ? ', ' : "");
    }
    $ret =~ s/, $//;
    
    $iCount--;
    $indents = "\t" x $iCount;
    
    $ret .= ($output_type eq "HTML" ? "$indents</DL>" : $output_type eq "JS" ? "}" : "");
    return($ret);
}