using LinearAlgebra, SparseArrays, InfiniteArrays, FillArrays, LazyArrays, Statistics, DSP, BandedMatrices, LazyBandedMatrices, Test, Base64
import InfiniteArrays: OrientedInfinity, SignedInfinity, InfUnitRange, InfStepRange, OneToInf, NotANumber
import LazyArrays: CachedArray, MemoryLayout, LazyLayout, DiagonalLayout, LazyArrayStyle, colsupport, DualLayout
import BandedMatrices: _BandedMatrix, BandedColumns
import Base.Broadcast: broadcasted, Broadcasted, instantiate

@testset "∞" begin
    @testset "∞" begin
        @test ∞ ≠ 1
        @test ∞ == ∞
        @test ∞ == Inf

        @test +∞ ≡ ∞

        @test isless(1, ∞)
        @test !isless(Inf, ∞)
        @test !isless(∞, Inf)
        @test !isless(∞, 1)

        @test !isless(∞, ∞)
        @test !(∞ < ∞)
        @test ∞ ≤ ∞
        @test !(∞ > ∞)
        @test ∞ ≥ ∞

        @test ∞ + ∞ ≡ ∞
        @test ∞ + 1 ≡ ∞
        @test *(∞) ≡ ∞
        @test ∞*∞ ≡ ∞
        @test ∞ - ∞ isa NotANumber

        @test one(∞) === 1
        @test zero(∞) === 0

        @test !isone(∞)
        @test !iszero(∞)

        @test max(1,∞) == max(∞,1) == ∞
        @test min(1,∞) == min(∞,1) == 1
        @test maximum([1,∞]) == ∞
        @test minimum([1,∞]) == 1

        @test string(∞) == "∞"

        @test Base.OneTo(∞) == OneToInf()

        @test isinf(∞)
        @test !isfinite(∞)

        @test div(∞, 2) == ∞
        @test fld(∞, 2) == ∞
        @test cld(∞, 2) == ∞
        @test div(2, ∞) == 0
        @test fld(2, ∞) == 0
        @test cld(2, ∞) == 1
        @test div(-2, ∞) == 0
        @test fld(-2, ∞) == -1
        @test cld(-2, ∞) == 0
        @test mod(2,∞) == 2
        @test div(∞,∞) isa NotANumber
        @test fld(∞,∞) isa NotANumber
        @test cld(∞,∞) isa NotANumber
        @test mod(∞,∞) isa NotANumber
        @test mod(∞,2) isa NotANumber
        @test_throws ArgumentError mod(-2,∞)

        @test min(∞, ∞) == ∞
        @test max(∞, ∞) == ∞
        @test min(3,∞) == 3
        @test max(3,∞) == ∞
    end

    @testset "SignedInfinity" begin
        @test SignedInfinity(∞) ≡ convert(SignedInfinity, ∞) ≡ SignedInfinity() ≡ 
                SignedInfinity(false) ≡ SignedInfinity(SignedInfinity())

        @test -∞ ≡ SignedInfinity(true)
        @test +∞ ≡ ∞

        @test sign(-∞) == -1
        @test angle(-∞) ≈ π

        @test ∞ == +∞ == SignedInfinity(∞)
        @test ∞ ≠  -∞
        @test 1-∞ == -∞
        @test 1-(-∞) ≡ SignedInfinity()
        @test (-∞) - 5 ≡ -∞

        @test (-∞)*(-∞) ≡ ∞*SignedInfinity(∞) ≡ SignedInfinity(∞)*∞

        @test  isless(-∞, 1)
        @test !isless(-∞, -Inf)
        @test !isless(-Inf, -∞)
        @test !isless(1, -∞)

        @test -∞ ≤ ∞
        @test SignedInfinity() ≤ ∞
        @test ∞ ≤ SignedInfinity()
        @test -∞ ≤ -∞
        @test !(∞ ≤ -∞)
        @test -∞ < ∞
        @test !(-∞ < -∞)
        @test !(SignedInfinity() < ∞)
        @test SignedInfinity() ≥ ∞
        @test ∞ ≥ SignedInfinity()
        @test !(-∞ > ∞)
        @test ∞ > -∞
        @test !(5 < -∞)
        @test -∞ < 5

        @test !(SignedInfinity(false) < SignedInfinity(false))
        @test SignedInfinity(false) ≤ SignedInfinity(false)
        @test SignedInfinity(true) < SignedInfinity(false)
        @test SignedInfinity(true) ≤ SignedInfinity(false)
        @test !(SignedInfinity(false) < SignedInfinity(true))
        @test !(SignedInfinity(false) ≤ SignedInfinity(true))
        @test !(SignedInfinity(true) < SignedInfinity(true))
        @test SignedInfinity(true) ≤ SignedInfinity(true)        

        @test SignedInfinity(true) + SignedInfinity(true) == SignedInfinity(true)
        @test SignedInfinity(false) + SignedInfinity(false) == SignedInfinity(false)
        @test SignedInfinity(true)+1 == SignedInfinity(true)
        @test SignedInfinity(false)+1 == SignedInfinity(false)

        @test string(-∞) == "-∞"

        @test (-∞) + (-∞) ≡ -∞
        @test (1∞) + (1∞) ≡ 1∞
        @test ∞ + (1∞) ≡ (1∞) + ∞ ≡ 1∞
        
        @test_throws ArgumentError ∞ + (-∞)
        @test_throws ArgumentError (1∞) + (-∞)
        @test_throws ArgumentError (-∞) + ∞

        @test ∞ - (-∞) ≡ ∞
        @test (-∞) - ∞ ≡ -∞
        @test (1∞) - (-∞) ≡ 1∞
        @test (-∞) - (1∞) ≡ -∞

        @test_throws ArgumentError ∞ - (1∞)
        @test_throws ArgumentError (1∞) - ∞
        @test_throws ArgumentError (1∞) - (1∞)
        @test_throws ArgumentError (-∞) - (-∞)
        @test_throws ArgumentError 0*∞
        @test_throws ArgumentError 0*(-∞)

        @test (-∞)*2 ≡ 2*(-∞) ≡ -2 * ∞ ≡ ∞ * (-2) ≡ (-2) * SignedInfinity() ≡ -∞
        @test (-∞)*2.3 ≡ 2.3*(-∞) ≡ -2.3 * ∞ ≡ ∞ * (-2.3) ≡ (-2.3) * SignedInfinity() ≡ -∞

        @test Base.OneTo(1*∞) == OneToInf()
        @test_throws ArgumentError Base.OneTo(-∞)

        @test isinf(-∞)
        @test !isfinite(-∞)

        @test [∞, -∞] isa Vector{SignedInfinity}

        @test mod(-∞, 5) isa NotANumber
        @test mod(-∞, -∞) isa NotANumber
        @test mod(5, SignedInfinity()) == 5
        @test_throws ArgumentError mod(5,-∞)

        @test min(-∞, ∞) ≡ min(∞, -∞) ≡ min(-∞, SignedInfinity()) ≡ -∞
        @test max(-∞, SignedInfinity()) ≡ SignedInfinity()
        @test max(∞, -∞) ≡ max(-∞,∞) ≡ ∞
    end

    @testset "OrientedInfinity" begin
        @test OrientedInfinity(∞) ≡ convert(OrientedInfinity, ∞) ≡ OrientedInfinity() ≡
            OrientedInfinity(false)

        @test OrientedInfinity(∞) == ∞
        @test ∞ == OrientedInfinity(∞)
        @test OrientedInfinity(∞) == SignedInfinity()
        @test SignedInfinity() == OrientedInfinity(∞)
        @test OrientedInfinity(-∞) == -∞
        @test  -∞ == OrientedInfinity(-∞)

        @test OrientedInfinity() + ∞ ≡ OrientedInfinity() + SignedInfinity() ≡ 
                ∞ + OrientedInfinity() ≡ SignedInfinity() + OrientedInfinity() ≡ OrientedInfinity()
        @test OrientedInfinity(true) + OrientedInfinity(true) == OrientedInfinity(true)
        @test OrientedInfinity(false) + OrientedInfinity(false) == OrientedInfinity(false)
        @test OrientedInfinity(true)+1 == OrientedInfinity(true)
        @test OrientedInfinity(false)+1 == OrientedInfinity(false)

        @test ∞ * OrientedInfinity() ≡ SignedInfinity() * OrientedInfinity() ≡ 
             OrientedInfinity() * ∞ ≡ OrientedInfinity() * SignedInfinity() ≡ OrientedInfinity()

        @test  2.0im*∞ ≡ ∞*2.0im ≡ 2.0im * SignedInfinity() ≡ SignedInfinity() * 2.0im ≡ OrientedInfinity(1/2)

        @test exp(im*π/4)*∞ == Inf+im*Inf
        @test exp(im*π/4)+∞ == ∞
    end
end

@testset "construction" begin
    @testset "Array constructor errors" begin
        @test_throws ArgumentError Array{Float64}(undef, ∞)
        @test_throws ArgumentError Array{Float64}(undef, ∞, ∞)
        @test_throws ArgumentError Array{Float64}(undef, 1, ∞)
        @test_throws ArgumentError Array{Float64}(undef, ∞, 1)

        @test_throws ArgumentError Vector{Float64}(undef, ∞)
        @test_throws ArgumentError Matrix{Float64}(undef, ∞, ∞)
        @test_throws ArgumentError Matrix{Float64}(undef, 1, ∞)
        @test_throws ArgumentError Matrix{Float64}(undef, ∞, 1)

        @test_throws ArgumentError Array{Float64}(undef, (∞,))
        @test_throws ArgumentError Array{Float64}(undef, (∞, ∞))
        @test_throws ArgumentError Array{Float64}(undef, (1, ∞))
        @test_throws ArgumentError Array{Float64}(undef, (∞, 1))

        @test_throws ArgumentError Vector{Float64}(undef, (∞,))
        @test_throws ArgumentError Matrix{Float64}(undef, (∞, ∞))
        @test_throws ArgumentError Matrix{Float64}(undef, (1, ∞))
        @test_throws ArgumentError Matrix{Float64}(undef, (∞, 1))

        @test Array{Float64}(undef, ()) isa Array{Float64,0}
        @test Array{Float64,0}(undef, ()) isa Array{Float64,0}
    end

    @testset "similar" begin
        a = 1:∞
        @test similar(a) isa CachedArray{Int}
        @test similar(a, Float64) isa CachedArray{Float64}
        @test similar(a, 5) isa Vector{Int}
        @test similar(a, (6,)) isa Vector{Int}
        @test similar(a, Float64, 5) isa Vector{Float64}
        @test similar(a, Float64, (6,)) isa Vector{Float64}
        @test similar(a, Float64, Base.OneTo(5)) isa Vector{Float64}
        @test similar(a, Float64, (Base.OneTo(5),)) isa Vector{Float64}
        @test similar(a, ∞) isa CachedArray{Int}
        @test similar(a, (∞,)) isa CachedArray{Int}
        @test similar(a, Float64, ∞) isa CachedArray{Float64}
        @test similar(a, Float64, (∞,)) isa CachedArray{Float64}
        @test similar(a, Float64, (∞,∞)) isa CachedArray{Float64}
        @test similar(a, Float64, Base.OneTo(∞)) isa CachedArray{Float64}
        @test similar(a, Float64, (Base.OneTo(∞),)) isa CachedArray{Float64}
        @test similar(a, Float64, (Base.OneTo(∞),Base.OneTo(∞))) isa CachedArray{Float64}

        @test similar([1,2,3],Float64,()) isa Array{Float64,0}

        @test similar(a, Float64, (2,∞)) isa CachedArray{Float64}
        @test similar(a, Float64, (∞,2)) isa CachedArray{Float64}
        @test similar(Array{Float64}, (2,∞)) isa CachedArray{Float64}
        @test similar(Array{Float64}, (∞,2)) isa CachedArray{Float64}
    end

    @testset "zeros/fill" begin
        a = zeros(1,∞)
        @test length(a) === ∞
        @test size(a) === (1,∞)
        @test a isa CachedArray{Float64}
        @test all(iszero,a[1,1:100])
        a[5] = 1
        @test a[1,1:100] == [zeros(4); 1; zeros(95)]

        a = fill(1,∞)
        @test length(a) === ∞
        @test size(a) === (∞,)
        @test a isa CachedArray{Int}
        @test all(x -> x===1,a[1:100])
        a[5] = 2
        @test a[1:100] == [fill(1,4); 2; fill(1,95)]
    end
end

@testset "ranges" begin
    @test size(10:1:∞) == (∞,)
    @testset "colon" begin
        @test @inferred(10:1:∞) === @inferred(range(10; step=1, length=∞))
        @inferred(1:0.2:∞)  === @inferred(range(1; step=0.2, length=∞))
        @inferred(1.0:0.2:∞)  === @inferred(range(1.0; step=0.2, length=∞))
        @inferred(1:∞) === @inferred(range(1; length=∞))
    end
    @test_throws ArgumentError 2:-.2:∞
    @test_throws ArgumentError 0.0:-∞
    @test_throws ArgumentError ∞:-1:1

    @test_throws ArgumentError (2:.2:-∞)
    @test_throws ArgumentError (2.:.2:-∞)
    @test_throws ArgumentError (1:-∞)    

    @testset "indexing" begin
        L32 = @inferred(Int32(1):∞)
        L64 = @inferred(Int64(1):∞)
        @test @inferred(L32[1]) === Int32(1) && @inferred(L64[1]) === Int64(1)
        @test L32[2] == 2 && L64[2] == 2
        @test L32[3] == 3 && L64[3] == 3
        @test L32[4] == 4 && L64[4] == 4

        @test @inferred((1.0:∞)[1]) === 1.0
        @test @inferred((1.0f0:∞)[1]) === 1.0f0
        @test @inferred((Float16(1.0):∞)[1]) === Float16(1.0)

        @test @inferred((0.1:0.1:∞)[2]) === 0.2
        @test @inferred((0.1f0:0.1f0:∞)[2]) === 0.2f0
        @test @inferred((1:∞)[1:4]) === 1:4
        @test @inferred((1.0:∞)[1:4]) === 1.0:4
        @test (2:∞)[1:4] == 2:5
        @test (1:∞)[2:5] === 2:5
        @test (1:∞)[2:2:5] === 2:2:4
        @test (1:2:∞)[2:6] === 3:2:11
        @test (1:2:∞)[2:3:7] === 3:6:13

        @test isempty((1:∞)[5:4])
        @test_throws BoundsError (1:∞)[8:-1:-2]
    end
    @testset "length" begin
        @test length(.1:.1:∞) == ∞
        @test length(1.1:1.1:∞) == ∞
        @test length(1.1:1.3:∞) == ∞
        @test length(1:1:∞) == ∞
        @test length(1:.2:∞) == ∞
        @test length(1.:.2:∞) == ∞
        @test length(2:-.2:-∞) == ∞
        @test length(2.:-.2:-∞) == ∞
    end

    @testset "intersect" begin
        @test intersect(1:∞, 2:3) == 2:3
        @test intersect(2:3, 1:∞) == 2:3
        @test intersect(1:∞, 2:∞) == 2:∞
        @test intersect(2:∞, 1:∞) == 2:∞
        @test intersect(-3:∞, 2:8) == 2:8
        @test intersect(1:∞, -2:3:15) == 1:3:15
        @test intersect(1:∞, -2:3:∞) == 1:3:∞
        @test intersect(1:11, -2:2:∞) == intersect(-2:2:∞,1:11) == 2:2:10
        @test intersect(1:∞, -2:1:15) == 1:15
        @test intersect(1:∞, 15:-1:-2) == 1:15
        @test intersect(1:∞, 15:-4:-2) == 3:4:15
        @test intersect(-20:∞, -10:3:-2) == -10:3:-2
        @test isempty(intersect(-5:5, -6:13:∞))
        @test isempty(intersect(1:∞, 15:4:-2))

        @test @inferred(intersect(0:3:∞, 0:4:∞)) == intersect(0:4:∞, 0:3:∞) == 0:12:∞

        @test intersect(24:-3:0, 0:4:∞) == 0:12:24
        @test_throws ArgumentError intersect(1:6:∞, 0:4:∞) # supporting empty would break type inferrence

        @test intersect(1:∞,3) == 3:3
        @test intersect(1:∞, 2:∞, UnitRange(3,7), UnitRange(4,6)) == UnitRange(4,6)

        @test intersect(1:∞, 2) === intersect(2, 1:∞) === 2:2
        @test_skip intersect(1.0:∞, 2) == intersect(2, 1.0:∞) == [2.0] # gives infinite loop
    end

    @testset "sort/sort!/partialsort" begin
        @test sort(1:∞) ≡ sort!(1:∞) ≡ 1:∞
        @test sort(2:2:∞) ≡ sort!(2:2:∞) ≡ 2:2:∞
        @test_throws ArgumentError sort(2:-2:-∞)
        @test_throws ArgumentError sort!(2:-2:-∞)
    end
    @testset "in" begin
        @test 0 in UInt(0):100:∞
        @test 0 in 0:-100:-∞
        @test ∞ ∉ UInt(0):100:∞

        @test !(3.5 in 1:∞)
        @test (3 in 1:∞)
        @test (3 in 5:-1:-∞)

        let r = 0.0:0.01:∞
            @test (r[30] in r)
        end
        let r = (-4*Int64(maxintfloat(Int === Int32 ? Float32 : Float64))):∞
            @test (3 in r)
            @test (3.0 in r)
        end
    end
    @testset "in() works across types, including non-numeric types (#21728)" begin
        @test 1//1 in 1:∞
        @test 1//1 in 1.0:∞
        @test !(5//1 in 6:∞)
        @test !(5//1 in 6.0:∞)
        @test Complex(1, 0) in 1:∞
        @test Complex(1, 0) in 1.0:∞
        @test Complex(1.0, 0.0) in 1:∞
        @test Complex(1.0, 0.0) in 1.0:∞
        @test_skip !(Complex(1, 1) in 1:∞)  # this is an infinite-loop at the moment
        @test_skip !(Complex(1, 1) in 1.0:∞)
        @test_skip !(Complex(1.0, 1.0) in 1:∞)
        @test_skip !(Complex(1.0, 1.0) in 1.0:∞)
        @test !(π in 1:∞)
    end


    @testset "indexing range with empty range (#4309)" begin
        @test (3:∞)[5:4] == 7:6
        @test (0:2:∞)[7:6] == 12:2:10
    end

    @testset "indexing with negative ranges (#8351)" begin
        for a=[3:∞, 0:2:∞], b=[0:1, 2:-1:0]
            @test_throws BoundsError a[b]
        end
    end

    @testset "sums of ranges" begin
        @test sum(1:∞) ≡ mean(1:∞) ≡ median(1:∞) ≡ ∞
        @test sum(0:∞) ≡ mean(1:∞) ≡ median(1:∞) ≡ ∞
        @test sum(0:2:∞) ≡ mean(0:2:∞) ≡ median(0:2:∞) ≡ SignedInfinity(∞)
        @test sum(0:-2:-∞) ≡ mean(0:-2:-∞) ≡ median(0:-2:-∞) ≡ -∞
    end

    @testset "broadcasted operations with scalars" begin
        @test Base.BroadcastStyle(typeof(1:∞)) isa LazyArrayStyle{1}
        @test Base.BroadcastStyle(typeof(Base.Slice(1:∞))) isa LazyArrayStyle{1}

        @test broadcast(-, 1:∞, 2) ≡ -1:∞
        @test broadcast(-, 1:∞, 0.25) ≡ 1-0.25:∞
        @test broadcast(+, 1:∞, 2) ≡ 3:∞
        @test broadcast(+, 1:∞, 0.25) ≡ 1+0.25:∞
        @test broadcast(+, 1:2:∞, 1) ≡ 2:2:∞
        @test broadcast(+, 1:2:∞, 0.3) ≡ 1+0.3:2:∞
        @test broadcast(-, 1:2:∞, 1) ≡ 0:2:∞
        @test broadcast(-, 1:2:∞, 0.3) ≡ 1-0.3:2:∞
        @test broadcast(-, 2, 1:∞) ≡ 1:-1:-∞
        @test exp.((1:∞)') ≡ broadcast(exp, (1:∞)') ≡ exp.(1:∞)'
        @test exp.(transpose(1:∞)) ≡ broadcast(exp, transpose(1:∞)) ≡ transpose(exp.(1:∞))
        @test 1 .+ (1:∞)' ≡ broadcast(+, 1, (1:∞)') ≡ (2:∞)'
        @test 1 .+ transpose(1:∞) ≡ broadcast(+, 1, transpose(1:∞)) ≡ transpose(2:∞)
        @test (1:∞)' .+ 1 ≡ broadcast(+, (1:∞)', 1) ≡ (2:∞)'
        @test transpose(1:∞) .+ 1 ≡ broadcast(+, transpose(1:∞), 1) ≡ transpose(2:∞)
    end

    @testset "near-equal ranges" begin
        @test 0.0:0.1:∞ != 0.0f0:0.1f0:∞
    end

    @testset "comparing InfiniteUnitRanges and OneToInf" begin
        @test 1:2:∞ == 1:2:∞ != 1:3:∞ != 2:3:∞ == 2:3:∞ != 2:∞
        @test 1:1:∞ == 1:∞ == 1:∞ == OneToInf() == OneToInf()
    end

    @testset "Base.OneTo (misleading) overrides" begin
        @test Base.OneTo{BigInt}(∞) isa OneToInf{BigInt}
        @test Base.OneTo(∞) isa OneToInf{Int}
    end

    @testset "issue #6973" begin
        r1 = 1.0:0.1:∞
        r2 = 1.0f0:0.2f0:∞
        r3 = 1:2:∞
        @test r1 + r1 == 2*r1
        @test_broken r1 + r2 == 2.0:0.3:∞
        @test (2r1)-3r1 == -1:(2step(r1)-3step(r1)):-∞
        @test_broken (r1 + r2) - r2 == r1
        @test r1 + r3 == 2.0:2.1:∞
        @test r3 + r3 == 2 * r3
    end

    @testset "Preservation of high precision upon addition" begin
        let r = (-0.1:0.1:∞) + broadcast(+, -0.3:0.1:∞, 1e-12)
            @test_broken r[3] == 1e-12
        end
    end

    @testset "issue #8584" begin
        @test (0:1//2:∞)[1:2:3] == 0:1//1:1
    end

    @testset "issue #9962" begin
        @test eltype(0:1//3:∞) <: Rational
        @test (0:1//3:∞)[1] == 0
        @test (0:1//3:∞)[2] == 1//3
    end
    @testset "converting ranges (issue #10965)" begin
        @test promote(0:∞, UInt8(2):∞) === (0:∞, 2:∞)
        @test convert(InfUnitRange{Int}, 0:∞) === 0:∞
        @test convert(InfUnitRange{Int128}, 0:∞) === Int128(0):∞

        @test InfUnitRange{Int16}(1:∞) ≡ AbstractVector{Int16}(1:∞) ≡
                AbstractArray{Int16}(1:∞) ≡ Int16(1):∞

        @test OneToInf{Int16}(OneToInf()) ≡ AbstractVector{Int16}(OneToInf()) ≡
                AbstractArray{Int16}(OneToInf()) ≡ OneToInf{Int16}()

        @test promote(0:1:∞, UInt8(2):UInt8(1):∞) === (0:1:∞, 2:1:∞)
        @test convert(InfStepRange{Int,Int}, 0:1:∞) === 0:1:∞
        @test convert(InfStepRange{Int128,Int128}, 0:1:∞) === Int128(0):Int128(1):∞

        @test promote(0:1:∞, 2:∞) === (0:1:∞, 2:1:∞)
        @test convert(InfStepRange{Int128,Int128}, 0:∞) === Int128(0):Int128(1):∞
        @test convert(InfStepRange, 0:∞) === 0:1:∞
        @test convert(InfStepRange{Int128,Int128}, 0.:∞) === Int128(0):Int128(1):∞


        @test_broken promote(0f0:inv(3f0):∞, 0.:2.:∞) === (0:1/3:∞, 0.:2.:∞)

        @test promote(0:1/3:∞, 0:∞) === (0:1/3:∞, 0.:1.:∞)

        @test AbstractArray{Float64}(1:2:∞) ≡ AbstractVector{Float64}(1:2:∞) ≡ 
                convert(AbstractVector{Float64}, 1:2:∞) ≡ convert(AbstractArray{Float64}, 1:2:∞)
    end

    @testset "inf-range[inf-range]" begin
        @test (1:∞)[1:∞] == 1:∞
        @test (1:∞)[OneToInf()] == 1:∞
        @test (1:∞)[2:∞] == 2:∞
        @test_throws BoundsError (1:∞)[-1:∞]
        @test (1:-1:-∞)[1:∞] == 1:-1:-∞
    end

    @testset "OneToInf" begin
        let r = OneToInf()
            @test !isempty(r)
            @test length(r) == ∞
            @test size(r) == (∞,)
            @test step(r) == 1
            @test first(r) == 1
            @test last(r) == ∞
            @test minimum(r) == 1
            @test maximum(r) == ∞
            @test r[2] == 2
            @test r[2:3] === 2:3
            @test_throws BoundsError r[0]
            @test broadcast(+, r, 1) === 2:∞
            @test 2*r === 2:2:∞
            @test r + r === 2:2:∞

            @test r - r === Zeros{Int}(∞)

            @test intersect(r, Base.OneTo(2)) == Base.OneTo(2)
            @test intersect(r, 0:5) == 1:5
            @test intersect(r, 2) === intersect(2, r) === 2:2

            @test Base.unsafe_indices(Base.Slice(r)) == (r,)
        end
    end

    @testset "show" begin
        # NOTE: Interpolating Int to ensure it's displayed properly across 32- and 64-bit
        @test summary(1:∞) == "∞-element InfUnitRange{$Int} with indices OneToInf()"
        @test Base.inds2string(axes(1:∞)) == "OneToInf()"
    end

    @testset "end" begin
        @test Base.OneTo(∞)[end] ≡ Base.OneTo(∞)[∞] ≡ ∞
        @test (1:∞)[end] ≡ (1:∞)[∞] ≡ ∞
        @test (1:2:∞)[end] ≡ (1:2:∞)[∞] ≡ ∞
        @test (1.0:2:∞)[end] ≡ (1.0:2:∞)[∞] ≡ ∞
    end

    @testset "union" begin
        @test @inferred((1:∞) ∪ (3:∞)) ≡ @inferred((3:∞) ∪ (1:∞)) ≡ 1:∞
        @test @inferred((1:∞) ∪ (3:1:∞)) ≡ @inferred((3:1:∞) ∪ (1:∞)) ≡ 1:1:∞
        @test @inferred((2:2:∞) ∪ (4:2:∞)) ≡ 2:2:∞
        @test (2.0:1.5:∞) ∪ (3.5:1.5:∞) ≡ 2.0:1.5:∞
        @test (1:∞) ∪ (2:2:∞) ≡ 1:1:∞
        @test (6:4:∞) ∪ (2:2:∞) ≡ 2:2:∞
        @test_throws ArgumentError (3:∞) ∪ (2:2:∞)
        @test_throws ArgumentError (2:2:∞) ∪ (3:∞)
        @test_throws ArgumentError (2:3:∞) ∪ (2:2:∞)
    end

    @testset "adjoint indexing" begin
        a = (1:∞)'
        @test a[:,:] ≡ a
        @test a[1,:] ≡ 1:∞
        @test a[1,2:2:end] ≡ 2:2:∞
    end
end

@testset "fill" begin
    @testset "fill sizes" begin
        for A in (Zeros(∞), Fill(1,∞), Ones(∞), 
                    Zeros(5,∞), Ones(5,∞), Fill(1,5,∞),
                    Zeros(∞,5), Ones(∞,5), Fill(1,∞,5),
                    Zeros(∞,∞), Ones(∞,∞), Fill(1,∞,∞))
            @test length(A) ≡ ∞
        end
        @test size(Zeros(∞,5)) ≡ (∞,5)
        @test size(Zeros(5,∞)) ≡ (5,∞)
    end

    @testset "Fill indexing" begin
        B = Ones(∞,∞)
        @test IndexStyle(B) == IndexCartesian()
        V = view(B,:,1)
        @test_broken size(V) == (∞,1)
        V = view(B,1,:)
        @test size(V) == (∞,)
        V = view(B,1:1,:)
        @test size(V) == (1,∞)
    end

    @testset "Fill reindex" begin
        F = Fill(2.0,2,∞)
        @test reshape(F,∞) ≡ reshape(F,OneToInf()) ≡ reshape(F,(OneToInf(),)) ≡ reshape(F,Val(1)) ≡ Fill(2.0,∞)
    end

    @testset "adjtrans copy" begin
        @test copy((1:∞)') ≡ (1:∞)'
        @test copy(transpose(1:∞)) ≡ transpose(1:∞)
    end

    @testset "Fill slices" begin
        A = Fill(2,∞,∞)
        Z = Zeros(∞,∞)
        @test A[:,1] ≡ A[1,:] ≡ A[1:∞,1] ≡ Fill(2,∞)
        @test Z[:,1] ≡ Z[1,:] ≡ Z[1:∞,1] ≡ Zeros(∞)
    end
end

@testset "diagonal" begin
    D = Diagonal(1:∞)
    @test D[1:10,1:10] == Diagonal(1:10)
    @test_broken D^2 isa Diagonal
    @test D*D isa Diagonal
    @test MemoryLayout(typeof(D.diag)) == LazyLayout()
    @test MemoryLayout(typeof(D)) == DiagonalLayout{LazyLayout}()
    @test Base.BroadcastStyle(typeof(D)) == LazyArrayStyle{2}()
    @test Base.BroadcastStyle(typeof(permutedims(D.diag))) == LazyArrayStyle{2}()
    bc = broadcasted(*,Ones(∞,∞),permutedims(D.diag))
    @test bc isa Broadcasted{LazyArrayStyle{2}}
    @test instantiate(bc) isa Broadcasted{LazyArrayStyle{2}}
    @test copy(instantiate(bc)) isa BroadcastArray
    @test broadcast(*,Ones(∞,∞),permutedims(D.diag)) isa BroadcastArray
    @test Ones(∞,∞)*D isa BroadcastArray
    @test (Ones(∞,∞)*D)[1:10,1:10] == Ones(10,10)*D[1:10,1:10]
    @test @inferred(broadcast(*,Ones{Int}(∞),D)) ≡ @inferred(broadcast(*,D,Ones{Int}(∞))) ≡ D
    @test @inferred(broadcast(*,Ones(∞),D)) == @inferred(broadcast(*,D,Ones(∞))) == Diagonal(1.0:∞)
    @test @inferred(broadcast(*,Ones{Int}(∞)',D)) == @inferred(broadcast(*,D,Ones{Int}(∞)')) == D
    @test @inferred(broadcast(*,Ones(∞)',D)) == @inferred(broadcast(*,D,Ones(∞)')) == Diagonal(1.0:∞)
    @test @inferred(broadcast(*,Fill(2,∞)',D)) ≡ @inferred(broadcast(*,D,Fill(2,∞)')) ≡ 2D

    @test Eye{Int}(∞) * D ≡ Eye{Int}(∞) * D ≡ D
    @test Eye(∞) * D == Eye(∞) * D == D
end

@testset "concat" begin
    @testset "concat indexing" begin
        A = Vcat(1:10, 1:∞)
        @test @inferred(length(A)) == ∞
        @test @inferred(A[5]) == A[15] == 5
        @test A[end] == @inferred(A[∞]) == ∞
        @test_throws BoundsError Vcat(1:10)[∞]

        A = Vcat(Ones(1,∞), Zeros(2,∞))
        @test @inferred(size(A)) == (3,∞)
        @test @inferred(A[1,5]) == 1
        @test @inferred(A[3,5]) == 0
        @test_throws BoundsError A[4,1]

        A = Vcat(Ones{Int}(1,∞), Diagonal(1:∞))
        @test @inferred(size(A)) ≡ (∞,∞)
        @test @inferred(A[1,5]) ≡ 1
        @test @inferred(A[5,5]) ≡ 0
        @test @inferred(A[6,5]) ≡ 5
        @test_throws BoundsError A[-1,1]

        A = Vcat(Ones{Float64}(1,∞), Diagonal(1:∞))
        @test @inferred(size(A)) ≡ (∞,∞)
        @test @inferred(A[1,5]) ≡ 1.0
        @test @inferred(A[5,5]) ≡ 0.0
        @test @inferred(A[6,5]) ≡ 5.0
        @test_throws BoundsError A[-1,1]

        A = Vcat(1, Zeros(∞))
        @test @inferred(A[1]) ≡ 1.0
        @test @inferred(A[2]) ≡ 0.0

        A = Hcat(Ones(∞), Zeros(∞,2))
        @test @inferred(size(A)) == (∞,3)
        @test @inferred(A[5,1]) == 1
        @test @inferred(A[5,3]) == 0
        @test_throws BoundsError A[1,4]

        A = Hcat(Ones{Int}(∞), Diagonal(1:∞))
        @test @inferred(size(A)) ≡ (∞,∞)
        @test @inferred(A[5,1]) ≡ 1
        @test @inferred(A[5,5]) ≡ 0
        @test @inferred(A[5,6]) ≡ 5
        @test_throws BoundsError A[-1,1]

        A = Hcat(1, (1:∞)')
        @test A[1,:] isa Vcat{<:Any,1}
        @test A[1,:][1:10] == A[1,1:10]
    end

    # This should be generalized, but it at the moment
    # it is restricted to a single Number. Support smart
    # addition for any number of Number/SVector's would be better
    # allowibng for the tail to be variable lenth
    @testset "Vcat special case" begin
        @test Vcat(1,Zeros{Int}(∞)) + Vcat(3,Zeros{Int}(∞)) ≡
            Vcat(1,Zeros{Int}(∞)) .+ Vcat(3,Zeros{Int}(∞)) ≡
            Vcat(4,Zeros{Int}(∞))

            size(Vcat(1:∞)) ≡ (∞,)
    end

    @testset "Vcat infrange getindex" begin
        x = Vcat(1, Fill(2,∞))
        @test x[1:end] ≡ x[1:∞] ≡ x
        @test x[3:end] ≡ x[3:∞] ≡ Fill(2,∞)
    end

    @testset "maximum/minimum Vcat" begin
        x = Vcat(1:2, [1,1,1,1,1], 3, Fill(4,∞))
        @test maximum(x) == 4
        @test minimum(x) == 1
    end

    @testset "special vcat" begin
        @test [1; Zeros(∞)][1:10] == [1; zeros(9)]
        @test [[1,2,3]; Zeros(∞)][1:10] == [1;2;3;zeros(7)]
        @test [1; zeros(∞)] isa CachedArray
        @test [[1,2,3]; zeros(∞)] isa CachedArray

        @test [1; 2; zeros(Int,∞)] isa CachedArray
        @test [1; 2; 3; zeros(Int,∞)] isa CachedArray
        @test [[1,2]; 3; zeros(Int,∞)] isa CachedArray
        @test [2; [1,2]; 3; zeros(Int,∞)] isa CachedArray
    end

    @testset "sparse print" begin
        A = Vcat(1, Zeros(∞))
        @test colsupport(A,1) == 1:1
        @test Base.replace_in_print_matrix(A, 2, 1, "0") == "⋅"
        if VERSION ≤ v"1.5"
			@test stringmime("text/plain", A; context=(:limit => true)) == 
					"vcat($Int, ∞-element Zeros{Float64,1,Tuple{OneToInf{$Int}}} with indices OneToInf()) with indices OneToInf():\n 1.0\n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n ⋮"
		else
			@test stringmime("text/plain", A; context=(:limit => true)) == 
					"vcat($Int, ∞-element Zeros{Float64, 1, Tuple{OneToInf{$Int}}} with indices OneToInf()) with indices OneToInf():\n 1.0\n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n  ⋅ \n ⋮"
		end
        A = Vcat(Ones{Int}(1,∞), Diagonal(1:∞))
        @test Base.replace_in_print_matrix(A, 2, 2, "0") == "⋅"
    end

    @testset "copymutable" begin
        @test Base.copymutable(Vcat(1., Zeros(∞))) isa CachedArray
        @test Base.copymutable(Vcat([1.], Zeros(∞))) isa CachedArray
        @test Base.copymutable(Vcat([1.,2.], zeros(∞))) isa CachedArray
        @test Base.copymutable(Vcat(1.,2., zeros(∞))) isa CachedArray
    end

    @testset "infinite indexing" begin
        a = Vcat(1, 1:∞)
        @test a[:] isa Vcat
        @test a[3:∞] ≡ 2:∞
        @test a[3:2:∞] isa Vcat

        A = Vcat(Ones(1,∞), Fill(2,1,∞))
        @test A[:,:] == A
        @test A[:,2:∞] isa Vcat

        A = Vcat(Ones(5,5), Fill(2,∞,5))
        @test A[:,:] == A
        @test A[2:∞,:] isa Vcat

        A = Vcat(Ones(1,∞), Fill(2,∞,∞))
        @test A[:,:] == A
        @test A[2:∞,2:∞] isa Vcat
        @test A[2:∞,2:∞][1:10,1:10] == fill(2,10,10)
    end
end

@testset "broadcasting" begin
    @testset "∞ BroadcastArray" begin
        A = 1:∞
        B = BroadcastArray(exp, A)
        @test length(B) == ∞
        @test B[6] == exp(6)
        @test exp.(A) ≡ B
        @test B[2:∞] isa BroadcastArray
        B = Diagonal(1:∞) .+ 1
        @test B isa BroadcastArray{Int}
        @test B[1,5] ≡ 1
        @test B[6,6] == 6+1
        B = Diagonal(1:∞) - Ones{Int}(∞,∞) # lowers to broadcast
        @test B isa BroadcastArray{Int}
        @test B[1,5] ≡ -1
        @test B[6,6] == 6-1
    end

    @testset "Broadcast Fill Lowers" begin
        @test broadcast(+, Zeros{Int}(∞) , Fill(1,∞)) isa Fill
        @test broadcast(+, Zeros{Int}(∞) , Zeros(∞)) isa Zeros
        @test broadcast(*, Ones(∞), Ones(∞)) ≡ Ones(∞)
        @test broadcast(*, Ones{Int}(∞), 1:∞) ≡ broadcast(*, 1:∞, Ones{Int}(∞)) ≡ 1:∞
        @test broadcast(*, Fill(2,∞), 1:∞) ≡ broadcast(*, 1:∞, Fill(2,∞)) ≡ 2:2:∞
        @test broadcast(*, Fill([1,2],∞), 1:∞) isa BroadcastVector
        @test broadcast(*, Fill([1,2],∞), 1:∞)[1:3] == broadcast(*, 1:∞, Fill([1,2],∞))[1:3] == [[1,2],[2,4],[3,6]]

        @test broadcast(*, 1:∞, Ones(∞)') isa BroadcastArray
        @test broadcast(*, 1:∞, Fill(2,∞)') isa BroadcastArray
        @test broadcast(*, Diagonal(1:∞), Ones{Int}(∞)') ≡ broadcast(*, Ones{Int}(∞)', Diagonal(1:∞)) ≡ Diagonal(1:∞)
        @test broadcast(*, Diagonal(1:∞), Fill(2,∞)') ≡ broadcast(*, Fill(2,∞)', Diagonal(1:∞)) ≡ Diagonal(2:2:∞)
    end

    @testset "subview inf broadcast" begin
        b = BroadcastArray(exp, 1:∞)
        v = view(b, 3:∞) .+ 1
        @test v isa BroadcastArray
        @test b[3:10] .+ 1 == v[1:8]
    end
end

@testset "Cumsum and diff" begin
    @test cumsum(Ones(∞)) ≡ 1.0:1.0:∞
    @test cumsum(Fill(2,∞)) ≡ 2:2:∞
    @test cumsum(Ones{Int}(∞)) ≡ Base.OneTo(∞)
    @test cumsum(Ones{BigInt}(∞)) ≡ Base.OneTo{BigInt}(∞)

    @test diff(Base.OneTo(∞)) ≡ Ones{Int}(∞)
    @test diff(1:∞) ≡ Fill(1,∞)
    @test diff(1:2:∞) ≡ Fill(2,∞)
    @test diff(1:2.0:∞) ≡ Fill(2.0,∞)

    x = Vcat([3,4], Ones{Int}(5), 3, Fill(2,∞))
    y = @inferred(cumsum(x))
    @test y isa Vcat
    @test y[1:12] == cumsum(x[1:12])

    @test diff(x[1:10]) == diff(x)[1:9]
    @test diff(y)[1:20] == x[2:21]

    @test cumsum(x).args[2] ≡ 8:12
    @test last(y.args) == sum(x[1:9]):2:∞

    for r in (3:4:∞, 2:∞, Base.OneTo(∞))
        c = cumsum(r)
        @test c isa Cumsum
        @test c[1:20] == [c[k] for k=1:20] == cumsum(r[1:20])
        @test c == c
    end

    @test cumsum(1:∞)[2:∞][1:5] == cumsum(1:6)[2:end]
end

@testset "Sub-array" begin
    @test Ones(∞)[3:∞] ≡ Ones(∞)
    @test Ones{Int}(∞)[4:6] ≡ Ones{Int}(3)
    @test (1:∞)[3:∞] ≡ 3:∞
end

@testset "conv" begin
    @test conv(1:∞, [2]) ≡ conv([2], 1:∞) ≡ 2:2:∞
    @test conv(1:2:∞, [2]) ≡ conv([2], 1:2:∞) ≡ 2:4:∞
    @test conv(1:∞, Ones(∞))[1:5] == conv(Ones(∞),1:∞)[1:5] == [1,3,6,10,15]
    @test conv(Ones(∞), Ones(∞)) ≡ 1.0:1.0:∞
    @test conv(Ones{Int}(∞), Ones{Int}(∞)) ≡ Base.OneTo(∞)
    @test conv(Ones{Bool}(∞), Ones{Bool}(∞)) ≡ Base.OneTo(∞)
    @test conv(Fill{Int}(2,∞), Fill{Int}(1,∞)) ≡ conv(Fill{Int}(2,∞), Ones{Int}(∞)) ≡ 
                conv(Ones{Int}(∞), Fill{Int}(2,∞)) ≡ 2:2:∞
    @test conv(Ones{Int}(∞), [1,5,8])[1:10] == conv([1,5,8], Ones{Int}(∞))[1:10] == 
                    conv(fill(1,100),[1,5,8])[1:10] == conv([1,5,8], fill(1,100))[1:10]
    @test conv(Ones{Int}(∞), 1:4)[1:10] == conv(1:4, Ones{Int}(∞))[1:10] == 
                    conv(fill(1,100),collect(1:4))[1:10] == conv(collect(1:4), fill(1,100))[1:10]                    
end

@testset "Taylor ODE" begin
    e₁ = Vcat(1, Zeros(∞))
    D = Hcat(Zeros(∞), Diagonal(1:∞))
    I_inf = Eye(∞)
    @test I_inf isa Eye{Float64,OneToInf{Int}}
    @test axes(I_inf) == (OneToInf{Int}(), OneToInf{Int}())
    @test eltype(I_inf) == Float64
    @test Base.BroadcastStyle(typeof(I_inf)) == LazyArrays.LazyArrayStyle{2}()
    L = Vcat(e₁', I_inf + D)
    @test L[1:3,1:3] == [1.0 0.0 0.0;
                         1.0 1.0 0.0;
                         0.0 1.0 2.0]
end

@testset "show" begin
    @test repr(Vcat(1:∞)) == "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, …]"
    @test repr(Vcat(2,1:∞)) == "[2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, …]"
end

@testset "*" begin
    A = Fill(1,3,∞)
    B = Diagonal(1:∞)
    C = Vcat([1,2,3], Zeros(∞))
    D = Vcat(Fill(1,3,∞), Zeros(∞,∞))

    AB = A*B
    @test AB isa BroadcastArray
    @test size(AB) == (3,∞)
    @test (AB)[1:3,1:10] == Fill(1,3,10)*Diagonal(1:10)

    @test A*B*C isa ApplyArray
    @test size(A*B*C) == (3,)
    @test (A*B*C)[1] == 14
    @test A*B*C == fill(14,3)
    @test_throws BoundsError (A*B*C)[1:10,1:10]
    @test A*B*D isa ApplyArray
    @test (A*B*D)[1:3,1:5] == fill(6.0,3,5)
end

@testset "MemoryLayout" begin
    @test MemoryLayout(OneToInf{Int}) == LazyLayout()
    @test MemoryLayout(0:∞) == LazyLayout()
    @test MemoryLayout((0:∞)') == DualLayout{LazyLayout}()
    A = _BandedMatrix((0:∞)', ∞, -1, 1)
    @test MemoryLayout(A) == BandedColumns{LazyLayout}()
end

@testset "Banded" begin
    A = _BandedMatrix((0:∞)', ∞, -1, 1)
    @test (Eye{Int}(∞) * A).data ≡ A.data
    @test 2.0A isa BandedMatrix
    @test (2.0A)[1:10,1:10] == 2.0A[1:10,1:10]
    @test 2.0\A isa BandedMatrix
    @test (2.0\A)[1:10,1:10] == 2.0\A[1:10,1:10]
    @test A/2 isa BandedMatrix
    @test (A/2)[1:10,1:10] == (A/2)[1:10,1:10]

    @test A * Eye(∞) isa BandedMatrix
    @test A / Eye(∞) isa BandedMatrix
    @test Eye(∞) * A isa BandedMatrix
    @test Eye(∞) \ A isa BandedMatrix
end

@testset "reshaped" begin
    @test InfiniteArrays.ReshapedArray(1:6,(2,3)) == [1 3 5; 2 4 6]
    @test InfiniteArrays.ReshapedArray(1:∞,(1,∞))[1,1:10] == 1:10
    @test reshape(1:∞,1,∞) === InfiniteArrays.ReshapedArray(1:∞,(1,∞))
    @test permutedims(1:∞) isa InfiniteArrays.ReshapedArray
    @test permutedims(1:∞)[1,1:10] == (1:10)
    a = reshape(Vcat(Fill(1,1,∞),Fill(2,2,∞)),∞)
    @test a[1:7] == [1, 2, 2, 1, 2, 2, 1]
end

@testset "norm/dot" begin
    for p in (-Inf, 0, 0.1, 1, 2, 3, Inf)
        @test norm(Zeros(∞), p) == 0.0
        @test norm(Fill(5),p) ≈ norm(Array(Fill(5)),p) # tests tuple bug
        @test norm(Zeros{Float64}(),p) == 0.0 # tests tuple bug
    end
    @test norm([1; zeros(∞)]) ≡ 1.0
    @test dot([1; zeros(∞)], [1; zeros(∞)]) ≡ 1.0
    @test dot([1; zeros(∞)], 1:∞) ≡ 1.0
    @test dot(1:∞, [1; zeros(∞)]) ≡ 1.0
end

@testset "sub-Eye" begin
    @test bandwidths(view(Eye(∞),:,2:∞)) == (1,-1)
end

@testset "findfirst" begin
    @test findfirst(isequal(5), OneToInf()) == 5
    @test isnothing(findfirst(isequal(5.5), OneToInf()))
    @test isnothing(findfirst(isequal(-1), OneToInf()))
    @test findfirst(isequal(5), 2:∞) == 4
    @test isnothing(findfirst(isequal(5.5), 2:∞))
    @test isnothing(findfirst(isequal(-1), 2:∞))
    @test findfirst(isequal(4), 2:2:∞) == 2
    @test isnothing(findfirst(isequal(5), 2:2:∞))
    @test isnothing(findfirst(isequal(5.5), 2:2:∞))
    @test isnothing(findfirst(isequal(-1), 2:2:∞))

    @test searchsorted(Vcat(2,3:∞),10) == 9:9
    @test searchsortedfirst(Vcat(2,3:∞),10) == 9
    @test searchsortedlast(Vcat(2,3:∞),10) == 9
    @test searchsortedlast(Vcat(2,3:∞),0) == 0
end

@testset "checked" begin
    @test Base.Checked.checked_sub(1,∞) === -∞
    @test Base.Checked.checked_sub(∞,1) === ∞
    @test Base.Checked.checked_add(1,∞) === ∞
    @test Base.Checked.checked_add(∞,1) === ∞

    @test Base.Checked.checked_sub(1,-∞) === SignedInfinity(false)
    @test Base.Checked.checked_sub(-∞,1) === -∞
    @test Base.Checked.checked_add(1,-∞) === -∞
    @test Base.Checked.checked_add(-∞,1) === -∞
end

@testset "convert infrange" begin
    @test convert(AbstractArray{Float64}, 1:∞) ≡ convert(AbstractArray{Float64}, Base.OneTo(∞)) ≡ 
        convert(AbstractVector{Float64}, 1:∞) ≡ convert(AbstractVector{Float64}, Base.OneTo(∞)) ≡
        AbstractVector{Float64}(1:∞) ≡ AbstractVector{Float64}(Base.OneTo(∞)) ≡
        AbstractArray{Float64}(1:∞) ≡ AbstractArray{Float64}(Base.OneTo(∞)) ≡ InfUnitRange(1.0)

    @test convert(AbstractArray{Float64}, (1:∞)') ≡ convert(AbstractArray{Float64}, Base.OneTo(∞)') ≡ 
        convert(AbstractMatrix{Float64}, (1:∞)') ≡ convert(AbstractMatrix{Float64}, Base.OneTo(∞)') ≡
        AbstractMatrix{Float64}((1:∞)') ≡ AbstractMatrix{Float64}(Base.OneTo(∞)') ≡ 
        AbstractArray{Float64}((1:∞)') ≡ AbstractArray{Float64}(Base.OneTo(∞)') ≡ 
        InfUnitRange(1.0)'

    @test convert(AbstractArray{Float64}, transpose(1:∞)) ≡ convert(AbstractArray{Float64}, transpose(Base.OneTo(∞))) ≡ 
        convert(AbstractMatrix{Float64}, transpose(1:∞)) ≡ convert(AbstractMatrix{Float64}, transpose(Base.OneTo(∞))) ≡
        AbstractMatrix{Float64}(transpose(1:∞)) ≡ AbstractMatrix{Float64}(transpose(Base.OneTo(∞))) ≡ 
        AbstractArray{Float64}(transpose(1:∞)) ≡ AbstractArray{Float64}(transpose(Base.OneTo(∞))) ≡ 
        transpose(InfUnitRange(1.0))
end
