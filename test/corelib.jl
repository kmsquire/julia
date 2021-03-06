# ranges
@test size(10:1:0) == (0,)
@test length(1:.2:2) == 6
@test length(1.:.2:2.) == 6
@test length(2:-.2:1) == 6
@test length(2.:-.2:1.) == 6
@test length(2:.2:1) == 0
@test length(2.:.2:1.) == 0

@test length(1:0) == 0
@test length(0.0:-0.5) == 0
@test length(1:2:0) == 0
L32 = linspace(int32(1), int32(4), 4)
L64 = linspace(int64(1), int64(4), 4)
@test L32[1] == 1 && L64[1] == 1
@test L32[2] == 2 && L64[2] == 2
@test L32[3] == 3 && L64[3] == 3
@test L32[4] == 4 && L64[4] == 4

r = [5:-1:1]
@test r[1]==5
@test r[2]==4
@test r[3]==3
@test r[4]==2
@test r[5]==1

@test length(.1:.1:.3) == 3
@test length(1.1:1.1:3.3) == 3
@test length(1.1:1.3:3) == 2
@test length(1:1:1.8) == 1

let
    span = 5:20
    r = -7:3:42
    @test findin(r, span) == 5:10
    r = 15:-2:-38
    @test findin(r, span) == 1:6
end
@test isempty(findin(5+0*(1:6), 2:4))
@test findin(5+0*(1:6), 2:5) == 1:6
@test findin(5+0*(1:6), 2:7) == 1:6
@test findin(5+0*(1:6), 5:7) == 1:6
@test isempty(findin(5+0*(1:6), 6:7))
@test findin(5+0*(1:6), 5:5) == 1:6

@test intersect(1:5, 2:3) == 2:3
@test intersect(-3:5, 2:8) == 2:5
@test intersect(-8:-3, -8:-3) == -8:-3
@test intersect(1:5, 5:13) == 5:5
@test isempty(intersect(-8:-3, -2:2))
@test isempty(intersect(-3:7, 2:1))
@test intersect(1:11, -2:3:15) == 1:3:10
@test intersect(1:11, -2:2:15) == 2:2:10
@test intersect(1:11, -2:1:15) == 1:11
@test intersect(1:11, 15:-1:-2) == 1:11
@test intersect(1:11, 15:-4:-2) == 3:4:11
@test intersect(-20:-5, -10:3:-2) == -10:3:-7
@test isempty(intersect(-5:5, -6:13:20))
@test isempty(intersect(1:11, 15:4:-2))
@test isempty(intersect(11:1, 15:-4:-2))
@test intersect(-5:5, 1+0*(1:3)) == 1:1
@test isempty(intersect(-5:5, 6+0*(1:3)))
@test intersect(-15:4:7, -10:-2) == -7:4:-3
@test intersect(13:-2:1, -2:8) == 7:-2:1
@test isempty(intersect(13:2:1, -2:8))
@test isempty(intersect(13:-2:1, 8:-2))
@test intersect(5+0*(1:4), 2:8) == 5+0*(1:4)
@test isempty(intersect(5+0*(1:4), -7:3))
@test intersect(0:3:24, 0:4:24) == 0:12:24
@test intersect(0:4:24, 0:3:24) == 0:12:24
@test intersect(0:3:24, 24:-4:0) == 0:12:24
@test intersect(24:-3:0, 0:4:24) == 24:-12:0
@test intersect(24:-3:0, 24:-4:0) == 24:-12:0
@test intersect(1:3:24, 0:4:24) == 4:12:16
@test intersect(0:6:24, 0:4:24) == 0:12:24
@test isempty(intersect(1:6:2400, 0:4:2400))
@test intersect(-51:5:100, -33:7:125) == -26:35:79
@test intersect(-51:5:100, -32:7:125) == -11:35:94
@test intersect(0:6:24, 6+0*(0:4:24)) == 6:6:6
@test intersect(12+0*(0:6:24), 0:4:24) == Range(12, 0, 5)
@test isempty(intersect(6+0*(0:6:24), 0:4:24))
@test intersect(-10:3:24, -10:3:24) == -10:3:23
@test isempty(intersect(-11:3:24, -10:3:24))

@test !contains(1:5, 3.5)
@test contains(1:5, 3)
@test contains(5:-1:1, 3)
@test contains(3+0*(1:5), 3)
@test !contains(3+0*(1:5), 4)

r = 0.0:0.01:1.0
@test contains(r,r[30])
r = (-4*int64(maxintfloat(is(Int,Int32) ? Float32 : Float64))):5
@test contains(r,3)
@test contains(r,3.0)

# comprehensions
X = [ i+2j for i=1:5, j=1:5 ]
@test X[2,3] == 8
@test X[4,5] == 14
@test isequal(ones(2,3) * ones(2,3)', [3. 3.; 3. 3.])
@test isequal([ [1,2] for i=1:2, : ], [1 2; 1 2])
# where element type is a Union. try to confuse type inference.
foo32_64(x) = (x<2) ? int32(x) : int64(x)
boo32_64() = [ foo32_64(i) for i=1:2 ]
let a36 = boo32_64()
    @test a36[1]==1 && a36[2]==2
end
@test isequal([1,2,3], [a for (a,b) in enumerate(2:4)])
@test isequal([2,3,4], [b for (a,b) in enumerate(2:4)])

@test_fails (10.^[-1])[1] == 0.1
@test (10.^[-1.])[1] == 0.1

# tricky space sensitive syntax cases
@test [-1 ~1] == [(-1) (~1)]

# lexing typemin(Int64)
@test_fails parse("9223372036854775808")
@test_fails parse("-(9223372036854775808)")
@test_fails parse("-9223372036854775808^1")
@test (-9223372036854775808)^1 == -9223372036854775808
@test [1 -1 -9223372036854775808] == [1 -1 typemin(Int64)]

# dict
h = Dict()
for i=1:10000
    h[i] = i+1
end
for i=1:10000
    @test (h[i] == i+1)
end
for i=1:2:10000
    delete!(h, i)
end
for i=1:2:10000
    h[i] = i+1
end
for i=1:10000
    @test (h[i] == i+1)
end
for i=1:10000
    delete!(h, i)
end
@test isempty(h)
h[77] = 100
@test h[77]==100
for i=1:10000
    h[i] = i+1
end
for i=1:2:10000
    delete!(h, i)
end
for i=10001:20000
    h[i] = i+1
end
for i=2:2:10000
    @test h[i]==i+1
end
for i=10000:20000
    @test h[i]==i+1
end
h = {"a" => 3}
@test h["a"] == 3

let
    z = Dict()
    get_KeyError = false
    try
        z["a"]
    catch _e123_
        get_KeyError = isa(_e123_,KeyError)
    end
    @test get_KeyError
end

_d = {"a"=>0}
@test isa([k for k in filter(x->length(x)==1, collect(keys(_d)))], Vector{Any})

# issue #1821
let
    d = Dict{UTF8String, Vector{Int}}()
    d["a"] = [1, 2]
    @test_fails d["b"] = 1
    @test isa(repr(d), String)  # check that printable without error
end

# issue #2344
let
    bestkey(d, key) = key
    bestkey{K<:String,V}(d::Associative{K,V}, key) = string(key)
    bar(x) = bestkey(x, :y)
    @test bar([:x => [1,2,5]]) == :y
    @test bar(["x" => [1,2,5]]) == "y"
end

# issue #1438
type I1438T
    id
end
import Base.hash
hash(x::I1438T) = x.id

begin
    local seq, xs, s
    seq = [26,28,29,30,31,32,33,34,35,36,-32,-35,-34,-28,37,38,39,40,-30,
           -31,41,42,43,44,-33,-36,45,46,47,48,-37,-38,49,50,51,52,-46,-50,53]
    xs = [ I1438T(id) for id=1:53 ]
    s = Set()
    for id in seq
        if id > 0
            x = xs[id]
            add!(s, x)
            @test contains(s, x)                 # check that x can be found
        else
            delete!(s, xs[-id])
        end
    end
end

@test  isequal(Dict(), Dict())
@test  isequal({1 => 1}, {1 => 1})
@test !isequal({1 => 1}, {})
@test !isequal({1 => 1}, {1 => 2})
@test !isequal({1 => 1}, {2 => 1})

# Generate some data to populate dicts to be compared
data_in = [ (rand(1:1000), randstring(2)) for _ in 1:1001 ]

# Populate the first dict
d1 = Dict{Int, String}()
for (k,v) in data_in
    d1[k] = v
end
data_in = collect(d1)
# shuffle the data
for i in 1:length(data_in)
    j = rand(1:length(data_in))
    data_in[i], data_in[j] = data_in[j], data_in[i]
end
# Inserting data in different (shuffled) order should result in
# equivalent dict.
d2 = Dict{Int, String}()
for (k,v) in data_in
    d2[k] = v
end

@test  isequal(d1, d2)
d3 = copy(d2)
d4 = copy(d2)
# Removing an item gives different dict
delete!(d1, data_in[rand(1:length(data_in))][1])
@test !isequal(d1, d2)
# Changing a value gives different dict
d3[data_in[rand(1:length(data_in))][1]] = randstring(3)
!isequal(d1, d3)
# Adding a pair gives different dict
d4[1001] = randstring(3)
@test !isequal(d1, d4)

@test isequal(Dict(), sizehint(Dict(),96))

# Here is what currently happens when dictionaries of different types
# are compared. This is not necessarily desirable. These tests are
# descriptive rather than proscriptive.
@test !isequal({1 => 2}, {"dog" => "bone"})
@test isequal(Dict{Int, Int}(), Dict{String, String}())

# issue #2540
d = {x => 1
    for x in ['a', 'b', 'c']}
@test d == {'a'=>1, 'b'=>1, 'c'=> 1}

# issue #2629
d = (String => String)[ a => "foo" for a in ["a","b","c"]]
@test d == ["a"=>"foo","b"=>"foo","c"=>"foo"]

# ############# end of dict tests #############

# #################### set ####################

# show

# isempty
@test  isempty(Set())
@test !isempty(Set(1))
@test !isempty(Set("banana", "apple"))
@test !isempty(Set(1, 1:10, "pear"))

# isless
@test isless(Set(), Set(1))
@test isless(Set(1), Set(1,2))
@test !isless(Set(3), Set(1,2))
@test !(Set(3) > Set(1,2))
@test Set(1,2,3) > Set(1,2)
@test !(Set(3) <= Set(1,2))
@test !(Set(3) >= Set(1,2))
@test Set(1) <= Set(1,2)
@test Set(1,2) <= Set(1,2)
@test Set(1,2) >= Set(1,2)
@test Set(1,2,3) >= Set(1,2)
@test !(Set(1,2,3) >= Set(1,2,4))
@test !(Set(1,2,3) <= Set(1,2,4))

# add, length
s = Set()
@test isempty(s)
for i in 1:1000
    add!(s, i)
    @test (length(s) == i)
end

# delete!, has, contains
for i in 1:2:1000
    delete!(s, i)
end
for i in 1:2:1000
    @test !contains(s, i)
    @test  contains(s, i+1)
end

# elements
data_in = (1,"banana", ())
s = Set(data_in...)
data_out = collect(s)
@test is(typeof(data_out), Array{Any,1})
@test all(map(d->contains(data_out,d), data_in))
@test all(map(data_in) do d contains(data_out, d) end)
@test length(data_out) == length(data_in)

# homogeneous sets
@test is(typeof(Set(1,2,3)), Set{Int})
@test is(typeof(Set{Int}(1.0, 4//2, 3)), Set{Int})

# eltype
@test is(eltype(Set(1,"hello")), Any)
@test is(eltype(Set{String}()), String)

# no duplicates
s = Set(1,2,3)
@test length(s) == 3
add!(s,2)
@test length(s) == 3
delete!(s,2)
@test length(s) == 2

# union
s = union(Set(1,2), Set(3,4))
@test isequal(s, Set(1,2,3,4))
s = union(Set(5,6,7,8), Set(7,8,9))
@test isequal(s, Set(5,6,7,8,9))

# intersect
s = intersect(Set(1,2), Set(3,4))
@test isequal(s, Set())
s = intersect(Set(5,6,7,8), Set(7,8,9))
@test isequal(s, Set(7,8))
@test isequal(intersect(Set(2,3,1), Set(4,2,3), Set(5,4,3,2)), Set(2,3))

# setdiff
@test isequal(setdiff(Set(1,2,3), Set()), Set(1,2,3))
@test isequal(setdiff(Set(1,2,3), Set(1)),  Set(2,3))
@test isequal(setdiff(Set(1,2,3), Set(1,2)),  Set(3))
@test isequal(setdiff(Set(1,2,3), Set(1,2,3)), Set())
@test isequal(setdiff(Set(1,2,3), Set(4)),  Set(1,2,3))
@test isequal(setdiff(Set(1,2,3), Set(4,1)),  Set(2,3))

for (l,r) in ((Set(1,2),     Set(3,4)),
              (Set(5,6,7,8), Set(7,8,9)),
              (Set(1,2),     Set(3,4)),
              (Set(5,6,7,8), Set(7,8,9)),
              (Set(1,2,3),   Set()),
              (Set(1,2,3),   Set(1)),
              (Set(1,2,3),   Set(1,2)),
              (Set(1,2,3),   Set(1,2,3)),
              (Set(1,2,3),   Set(4)),
              (Set(1,2,3),   Set(4,1)))
    @test issubset(intersect(l,r), l)
    @test issubset(intersect(l,r), r)
    @test issubset(l, union(l,r))
    @test issubset(r, union(l,r))
    @test isequal(union(intersect(l,r),symdiff(l,r)), union(l,r))
end

# union!
s = Set(1,3,5,7)
union!(s,(2,3,4,5))
@test isequal(s,Set(1,2,3,4,5,7))

# setdiff!
s = Set(1,3,5,7)
setdiff!(s,(3,5))
@test isequal(s,Set(1,7))

# similar
s = similar(Set(1,"Banana"))
@test length(s) == 0
@test typeof(s) == Set{Any}
s = similar(Set{Float32}(2,3,4))
@test length(s) == 0
@test typeof(s) == Set{Float32}

# copy
data_in = (1,2,9,8,4)
s = Set(data_in...)
c = copy(s)
@test isequal(s,c)
add!(s,100)
add!(c,200)
@test !contains(c, 100)
@test !contains(s, 200)

# start, done, next
for data_in in ((7,8,4,5),
                ("hello", 23, 2.7, (), [], (1,8)))
    s = Set(data_in...)

    s_new = Set()
    for el in s
        add!(s_new, el)
    end
    @test isequal(s, s_new)
    
    t = tuple(s...)
    @test length(t) == length(s)
    for e in t
        @test contains(s,e)
    end
end

# zip
let i = 0
x = 1:2:8
y = 2:2:8
xy = 1:8
for (thisx, thisy) in zip(x, y)
    @test thisx == xy[i+=1]
    @test thisy == xy[i+=1]
end
end

# pop!
origs = Set(1,2,3,"apple")
s = copy(origs)
for i in 1:length(origs)
    el = pop!(s)
    @test !contains(s, el)
    @test contains(origs, el)
end
@test isempty(s)
# isequal
@test  isequal(Set(), Set())
@test !isequal(Set(), Set(1))
@test  isequal(Set{Any}(1,2), Set{Int}(1,2))
@test !isequal(Set{Any}(1,2), Set{Int}(1,2,3))

# Comparison of unrelated types seems rather inconsistent

@test  isequal(Set{Int}(), Set{String}())
@test !isequal(Set{Int}(), Set{String}(""))
@test !isequal(Set{String}(), Set{Int}(0))
@test !isequal(Set{Int}(1), Set{String}())

@test  isequal(Set{Any}(1,2,3), Set{Int}(1,2,3))
@test  isequal(Set{Int}(1,2,3), Set{Any}(1,2,3))

@test !isequal(Set{Any}(1,2,3), Set{Int}(1,2,3,4))
@test !isequal(Set{Int}(1,2,3), Set{Any}(1,2,3,4))

@test !isequal(Set{Any}(1,2,3,4), Set{Int}(1,2,3))
@test !isequal(Set{Int}(1,2,3,4), Set{Any}(1,2,3))

# ########## end of set tests ##########

## IntSet

s = IntSet(0,1,10,20,200,300,1000,10000,10002)
@test last(s) == 10002
@test first(s) == 0
@test length(s) == 9
@test pop!(s) == 10002
@test length(s) == 8
@test shift!(s) == 0
@test length(s) == 7
@test !contains(s,0)
@test !contains(s,10002)
@test contains(s,10000)
@test_fails first(IntSet())
@test_fails last(IntSet())

# Ensure subnormal flags functions don't segfault
@test any(ccall("jl_zero_subnormals", Uint8, (Uint8,), 1) .== [0x00 0x01])
@test any(ccall("jl_zero_subnormals", Uint8, (Uint8,), 0) .== [0x00 0x01])

# VersionNumber
@test VersionNumber(2,3,1) == VersionNumber(int8(2),uint32(3),int32(1)) == v"2.3.1"
@test v"2.3.0" < v"2.3.1" < v"2.4.8" < v"3.7.2"
