﻿#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Vim_")) && Vim.State.ft
a::
b::
c::
d::
e::
f::
g::
h::
i::
j::
k::
l::
m::
n::
o::
p::
q::
r::
s::
t::
u::
v::
w::
x::
y::
z::
+a::
+b::
+c::
+d::
+e::
+f::
+g::
+h::
+i::
+j::
+k::
+l::
+m::
+n::
+o::
+p::
+q::
+r::
+s::
+t::
+u::
+v::
+w::
+x::
+y::
+z::
0::
1::
2::
3::
4::
5::
6::
7::
8::
9::
`::
~::
!::
?::
@::
#::
$::
%::
^::
&::
*::
(::
)::
-::
_::
=::
+::
[::
{::
]::
}::
/::
\::
|::
:::
`;::
'::
"::
,::
<::
.::
>::
	Vim.State.last_ft := Vim.State.ft
	Vim.State.last_ft_char := Vim.State.ft_char
	Vim.Move.Move(Vim.State.ft)
Return

#If Vim.IsVimGroup() and (Vim.State.StrIsInCurrentVimMode("Vim_"))
f::Vim.State.SetMode("",, -1,, "f")
t::Vim.State.SetMode("",, -1,, "t")
`;::
	Vim.State.ft_char := Vim.State.last_ft_char
	Vim.Move.Move(Vim.State.last_ft)
Return