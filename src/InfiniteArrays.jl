module InfiniteArrays
using Base, Statistics, LinearAlgebra, FillArrays, LazyArrays, DSP

import Base: *, +, -, /, \, ==, isinf, isfinite, sign, signbit, angle, show, isless,
            fld, cld, div, min, max, minimum, maximum, mod,
            <, ≤, >, ≥, promote_rule, convert, unsafe_convert, copy,
            size, step, isempty, length, first, last, tail,
            getindex, setindex!, intersect, @_inline_meta,
            sort, sort!, issorted, sortperm, sum, in, broadcast,
            eltype, elsize, parent, parentindices, reinterpret,
            unaliascopy, dataids,
            real, imag, conj, transpose,
            exp, log, sqrt, cos, sin, tan, csc, sec, cot,
            cosh, sinh, tanh, csch, sech, coth, acos, asin, atan, acsc, asec, acot,
            acosh, asinh, atanh, acsch, asech, acoth, (:),
            AbstractMatrix, AbstractArray, checkindex, unsafe_length, unsafe_indices, OneTo,
            to_shape, _sub2ind, print_matrix, print_matrix_row, print_matrix_vdots,
            checkindex, Slice, IdentityUnitRange, @propagate_inbounds, @_propagate_inbounds_meta,
         	_in_range, _range, _rangestyle, Ordered,
         	ArithmeticWraps, ArithmeticUnknown, floatrange, reverse, unitrange_last,
         	AbstractArray, AbstractVector, Array, Vector, Matrix,
         	axes, (:), _sub2ind_recurse, broadcast, promote_eltypeof,
         	diff, cumsum, show_delim_array, show_circular, Int,
         	similar, _unsafe_getindex, string, zeros, fill, permutedims,
         	cat_similar, vcat, one, zero,
		 	reshape, ReshapedIndex, ind2sub_rs, _unsafe_getindex_rs,
            searchsorted, searchsortedfirst, searchsortedlast, Ordering, lt, Fix2, findfirst,
            cat_indices, cat_size, cat_similar, __cat, _ind2sub_recurse, union, intersect

using Base.Broadcast
import Base.Broadcast: BroadcastStyle, AbstractArrayStyle, Broadcasted, broadcasted,
                        @nexprs, @ncall, combine_eltypes, DefaultArrayStyle, instantiate, axistype

import LinearAlgebra: BlasInt, BlasFloat, norm, diag, diagm, ishermitian, issymmetric,
                             det, logdet, istriu, istril, adjoint, tr, AbstractTriangular,
                             norm2, norm1, normp, AdjOrTrans, HermOrSym

import Statistics: mean, median

import FillArrays: AbstractFill, getindex_value, fill_reshape, RectDiagonal
import LazyArrays: LazyArrayStyle, AbstractBandedLayout, MemoryLayout, LazyLayout, UnknownLayout,
                    ZerosLayout, AbstractArrayApplyStyle, CachedArray, CachedVector, ApplyLayout,
                    reshapedlayout, sub_materialize, LayoutMatrix, LayoutVector, _padded_sub_materialize, PaddedLayout

import DSP: conv

export ∞, Hcat, Vcat, Zeros, Ones, Fill, Eye, BroadcastArray, cache



include("Infinity.jl")
include("infrange.jl")
include("infarrays.jl")
include("reshapedarray.jl")

##
# Fill FillArrays
##

length(::Ones{<:Any,1,Tuple{OneToInf{Int}}}) = ∞
length(::Fill{<:Any,1,Tuple{OneToInf{Int}}}) = ∞
length(::Zeros{<:Any,1,Tuple{OneToInf{Int}}}) = ∞
length(::Ones{<:Any,2,Tuple{OneToInf{Int},OneToInf{Int}}}) = ∞
length(::Ones{<:Any,2,<:Tuple{OneToInf{Int},<:Any}}) = ∞
length(::Ones{<:Any,2,<:Tuple{<:Any,OneToInf{Int}}}) = ∞
length(::Fill{<:Any,2,Tuple{OneToInf{Int},OneToInf{Int}}}) = ∞
length(::Fill{<:Any,2,<:Tuple{OneToInf{Int},<:Any}}) = ∞
length(::Fill{<:Any,2,<:Tuple{<:Any,OneToInf{Int}}}) = ∞
length(::Zeros{<:Any,2,Tuple{OneToInf{Int},OneToInf{Int}}}) = ∞
length(::Zeros{<:Any,2,<:Tuple{OneToInf{Int},<:Any}}) = ∞
length(::Zeros{<:Any,2,<:Tuple{<:Any,OneToInf{Int}}}) = ∞

for op in (:norm2, :norm1)
   @eval $op(a::Zeros{T,N,NTuple{N,OneToInf{Int}}}) where {T,N} = norm(getindex_value(a))
end

normp(a::Zeros{T,N,NTuple{N,OneToInf{Int}}}, p) where {T,N} = norm(getindex_value(a))

for N=1:3
   for op in (:norm2, :norm1)
      @eval function $op(a::AbstractFill{T,$N,NTuple{$N,OneToInf{Int}}}) where {T,N}
         z = norm(getindex_value(a))
         iszero(z) && return z
         typeof(z)(Inf)
      end
   end
   @eval function normp(a::AbstractFill{T,$N,NTuple{$N,OneToInf{Int}}}, p) where {T,N }
      z = norm(getindex_value(a))
      iszero(z) && return z
      typeof(z)(Inf)
   end
end

for Typ in (:Number, :AbstractVector)
   @eval begin
      vcat(a::$Typ, b::AbstractFill{<:Any,1,<:Tuple{OneToInf}}) = Vcat(a, b)
      vcat(a::$Typ, c::CachedVector{<:Any,<:Any,<:AbstractFill{<:Any,1,<:Tuple{OneToInf}}}) =
         CachedArray(vcat(a, view(c.data,1:c.datasize[1])), c.array)
   end
end

vcat(a::AbstractMatrix, b::AbstractFill{<:Any,2,<:Tuple{OneToInf,OneTo}}) =
   Vcat(a, b)

cat_similar(A, T, shape::Tuple{Infinity}) = zeros(T,∞)
cat_similar(A::AbstractArray, T, shape::Tuple{Infinity}) =
   Base.invoke(cat_similar, Tuple{AbstractArray, Any, Any}, A, T, shape)

function Base.__cat(A, shape::NTuple{N,Infinity}, catdims, X...) where N
   offsets = zeros(Union{Int,Infinity}, N)
   inds = Vector{Union{UnitRange{Int},InfUnitRange{Int}}}(undef, N)
   concat = copyto!(zeros(Bool, N), catdims)
   for x in X
       for i = 1:N
           if concat[i]
               inds[i] = offsets[i] .+ cat_indices(x, i)
               offsets[i] += cat_size(x, i)
           else
               inds[i] = 1:shape[i]
           end
       end
       I::NTuple{N, Union{InfUnitRange{Int},UnitRange{Int}}} = (inds...,)
       if x isa AbstractArray
           copyto!(view(A, I...), x)
       else
           fill!(view(A, I...), x)
       end
   end
   return A
end

reshape(parent::AbstractArray, shp::Tuple{OneToInf, Vararg{Union{Integer,OneTo,OneToInf}}}) =
   reshape(parent, to_shape(shp))
reshape(parent::AbstractArray, shp::Tuple{Union{Integer,OneTo}, OneToInf, Vararg{Union{Integer,OneTo,OneToInf}}}) =
   reshape(parent, to_shape(shp))


# cat_similar(A, T, ::Tuple{Infinity}) = zeros(T, ∞)

##
# Temporary hacks for base support
##
OneTo(::Infinity) = OneToInf()
function OneTo(x::OrientedInfinity)
    iszero(x.angle) && return OneTo(∞)
    throw(ArgumentError("Cannot create infinite range with negative length"))
end
function OneTo(x::SignedInfinity)
   signbit(x) || return OneTo(∞)
   throw(ArgumentError("Cannot create infinite range with negative length"))
end
OneTo{T}(::Infinity) where T<:Integer = OneToInf{T}()
UnitRange(start::Integer, ::Infinity) = InfUnitRange(start)
UnitRange{T}(start::Integer, ::Infinity) where T<:Real = InfUnitRange{T}(start)
OneTo(a::OneToInf) = a
OneTo{T}(::OneToInf) where T<:Integer = OneToInf{T}()

Int(::Infinity) = ∞

axistype(::OneTo{T}, ::OneToInf{V}) where {T,V} = OneToInf{promote_type(T,V)}()
axistype(::OneToInf{V}, ::OneTo{T}) where {T,V} = OneToInf{promote_type(T,V)}()

# sort.jl
# returns the range of indices of v equal to x
# if v does not contain x, returns a 0-length range
# indicating the insertion point of x
function searchsorted(v::AbstractVector, x, ilo::Int, ::Infinity, o::Ordering)
    lo = ilo-1
    hi = ∞
    @inbounds while lo < hi-1
        m = isinf(hi) ? lo + 1000 : (lo+hi)>>>1
        if lt(o, v[m], x)
            lo = m
        elseif lt(o, x, v[m])
            hi = m
        else
            a = searchsortedfirst(v, x, max(lo,ilo), m, o)
            b = searchsortedlast(v, x, m, hi, o)
            return a : b
        end
    end
    return (lo + 1) : (hi - 1)
end


# index of the first value of vector a that is greater than or equal to x;
# returns length(v)+1 if x is greater than all values in v.
function searchsortedfirst(v::AbstractVector, x, lo::Int, hi::Infinity, o::Ordering)
   u = 1
   lo = lo - u
   hi = ∞
   @inbounds while lo < hi - u
      m = isinf(hi) ? lo + 1000 : (lo+hi)>>>1
      if lt(o, v[m], x)
         lo = m
      else
         hi = m
      end
   end
   return hi
end

# index of the last value of vector a that is less than or equal to x;
# returns 0 if x is less than all values of v.
function searchsortedlast(v::AbstractVector, x, lo::Int, hi::Infinity, o::Ordering)
   u = 1
   lo = lo - u
   hi = ∞
   @inbounds while lo < hi - u
       m = isinf(hi) ? lo + 1000 : (lo+hi)>>>1
       if lt(o, x, v[m])
           hi = m
       else
           lo = m
       end
   end
   return lo
end

##
# lazy sub_materialize
##

const InfAxes = Union{AbstractInfUnitRange,Slice{<:AbstractInfUnitRange},IdentityUnitRange{<:AbstractInfUnitRange}}

sub_materialize(_, V, ::Tuple{InfAxes}) = V
sub_materialize(_, V, ::Tuple{InfAxes,InfAxes}) = V
sub_materialize(_, V, ::Tuple{<:Any,InfAxes}) = V
sub_materialize(_, V, ::Tuple{InfAxes,Any}) = V

sub_materialize(::ApplyLayout{typeof(vcat)}, V::AbstractMatrix, ::Tuple{InfAxes,InfAxes}) = ApplyArray(V)
sub_materialize(::ApplyLayout{typeof(vcat)}, V::AbstractMatrix, ::Tuple{<:Any,InfAxes}) = ApplyArray(V)
sub_materialize(::ApplyLayout{typeof(vcat)}, V::AbstractMatrix, ::Tuple{InfAxes,Any}) = ApplyArray(V)

sub_materialize(::PaddedLayout, v::AbstractVector{T}, ::Tuple{InfAxes}) where T =
    _padded_sub_materialize(v)


end # module
