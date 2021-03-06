%
% SDF (Self-Describing Format) MatLab reader
% Copyright (c) 2015-2016, SDF Development Team
%
% Distributed under the terms of the BSD 3-clause License.
% See the LICENSE file for details.
%

function q = GetLagrangianMeshSDF(h);

global block;

fseek(h.fid, block.block_start + h.block_header_length, 'bof');

mults = fread(h.fid, block.ndims, 'float64');
for n=1:block.ndims
  labels{n} = { deblank(strtrim(char(fread(h.fid, h.ID_LENGTH, 'uchar'))')) };
end
for n=1:block.ndims
  units{n} = { deblank(strtrim(char(fread(h.fid, h.ID_LENGTH, 'uchar'))')) };
end
geometry = fread(h.fid, 1, 'int32');
extents = fread(h.fid, 2*block.ndims, 'float64');
npts = fread(h.fid, block.ndims, 'int32');
q.labels = labels;
q.units = units;

if block.datatype == h.DATATYPE.REAL4
    typestring = 'single';
elseif block.datatype == h.DATATYPE.REAL8
    typestring = 'double';
elseif block.datatype == h.DATATYPE.INTEGER4
    typestring = 'int32';
elseif block.datatype == h.DATATYPE.INTEGER8
    typestring = 'int64';
end

nelements = 1;
for n=1:block.ndims
    nelements = nelements * npts(n);
end
typesize = block.data_length / block.ndims / nelements;

%fseek(h.fid, block.data_location, 'bof');
offset = block.data_location;

tags = ['x' 'y' 'z' 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n'];
for n=1:block.ndims
    tagname = tags(n);
    block.map = memmapfile(h.filename, 'Format', ...
            {typestring npts' tagname}, 'Offset', offset, ...
            'Repeat', 1, 'Writable', false);
    q.(tagname) = block.map.data.(tagname);
    offset = offset + typesize * nelements;
end
