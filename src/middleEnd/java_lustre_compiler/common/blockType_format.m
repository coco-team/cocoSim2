function [ blockType_out ] = blockType_format( blockType )
%BLOCKTYPE_FORMAT

if BlockUtils.isCompareToMask(blockType)
    blockType_out = 'CompareTo';
elseif BlockUtils.isDetectMask(blockType)
    blockType_out = 'Detect';
else
    blockType_out = strrep(blockType, ' ', '');
    blockType_out = strrep(blockType_out, '-', '');
end
end

