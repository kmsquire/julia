## Based loosely on Java's BufferedReader
#
# A Buffered reader wraps an IO object
#
# mark(b::BufferedReader)     - marks a position in the wrapped IO object
# seekmark(b::BufferedReader) - seeks to the marked position 
#                               the mark is not removed
# unmark(b::BufferedReader)   - removes a mark
# ismarked(b::bufferedReader) - true if b is marked

const DEFAULT_BUFFER_SIZE = 8192

import Base: read, write, eof, position, close, nb_available

type BufferedReader <: IO
    buffer::IOBuffer
    io::IO
    marked::Bool
end

BufferedReader(io::IO, maxsize::Int) = BufferedReader(IOBuffer(maxsize), io, false)
BufferedReader(io::IO) = BufferedReader(IOBuffer(), io, false)

function read(br::BufferedReader, ::Type{Uint8})
    if nb_available(br.buffer) > 0
        read(br.buffer, Uint8)
    elseif br.marked
        if nb_writable(br.buffer) > 0
            a = read(br.io, Uint8)
            write(br.buffer, a)
            return a
        else
            br.marked = false
            seekstart(br.buffer)
            truncate(br.buffer, 0)
            resize!(br.buffer.data, 0)
            return read(br.io, Uint8)
        end
    else
        read(br.io, Uint8)
    end
end

function read{T}(br::BufferedReader, a::Array{T})
    !isbits(T) && error("Read from BufferedReader only supports bits types or arrays of bits types; got ", string(T), ".")
    nb = length(a)*sizeof(T)
    nba = nb_available(br.buffer)

    if nba > 0
        if nba >= nb
            return read(br.buffer, a)
        end
        read(br.buffer, sub(a, 1:nba))
        read(br.io, sub(a, (nba+1):endof(a)))
        if br.marked
            write(br.buffer, sub(a, (nba+1):endof(a))); end
        return a
    elseif br.marked
        if nb_writable(br.buffer) >= nb
            read(br.io, a)
            write(br.buffer, a)
            return a
        else
            br.marked = false
            seekstart(br.buffer)
            truncate(br.buffer, 0)
            resize!(br.buffer.data, 0)
            return read(br.io, a)
        end
    else
        read(br.io, a)
    end 
end

write(br::BufferedReader, args...) = error("Writing to a BufferedReader is not possible.")

function mark(br::BufferedReader)
    Base.compact(br.buffer)
    br.marked = true
end

function mark(f::Function, br::BufferedReader)
    local ret
    try
        mark(br)
        ret = f(br)
    finally
        seekmark(br)
        unmark(br)
    end
    ret
end

function mark(f::Function, io::Union(IOStream, File), args...)
    # For IOStream, File, attempt to reset the stream back
    # to starting position at exit
    pos = position(io)

    br = BufferedReader(io, args...)
    mark(br)

    local ret
    try
        ret = f(br)
    finally
        seek(io, pos)
    end
    ret
end

function mark(f::Function, io::IO, args...)
    br = BufferedReader(io, args...)
    mark(br)
    f(br)
end

seekmark(br::BufferedReader) = (if br.marked; seekstart(br.buffer); end; br.marked)
ismarked(br::BufferedReader) = br.marked
unmark(br::BufferedReader) = (br.marked = false)

eof(br::BufferedReader) = eof(br.buffer) && eof(br.io)
close(br::BufferedReader) = (seekstart(br.buffer); truncate(br.buffer, 0); br.marked = false; close(br.io))
position(br::BufferedReader) = br.marked ? position(br.io) : position(br.io)-nb_available(br.buffer)
nb_available(br::BufferedReader) = nb_available(br.buffer) + nb_available(br.io)

