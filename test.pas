program testprog;
label 9999;
const x = 5; y = x;
type
  testenum = (zero, one, two);
  testarr = array [0..9,5..20] of integer;
  testrecord = record
                a, b, c, d : integer;
                e, f, g, h : real
               end;
  testset = set of char;
  testset2 = set of (club, diamond, heart, spade);
  testset3 = set of testenum;
begin
end.
