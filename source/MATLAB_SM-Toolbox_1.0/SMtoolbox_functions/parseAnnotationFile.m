%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: parseAnnotationFile.m
% Date of Revision: 2013-06
% Programmer: Harald G. Grohganz, University of Bonn (grohganz@cs.uni-bonn.de)
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   Reads several types of annotation files, and parses them to segment
%   structs.
%   This function can read annotation files consisting of lines of the following structure
%       (type) number (number) (label|"label with spaces")
%   All parts in brackets are optional.
%
%   Type may consist of upper- and lowercase characters and "_" only.
%   If this field is empty, it will be ignored.
%   Numbers can be either integers or floating point numbers.
%   A label consists of upper- and lowercase characters and ":" only.
%   If a label is surrounded by quotation marks, it can contain whitespaces
%   and special characters, too.
%
%   The parts can be separated by whitespaces, tabs, and commas.
%
%   Input:
%       filename : path to a annotation text file
%
%   Output:
%       annoSeg : struct of segments as input for visualizeSegFamily
%       sideinfo : additional information
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reference:
%   If you use the 'SM toobox' please refer to:
%   [MJG13] Meinard Müller, Nanzhu Jiang, Harald Grohganz
%   SM Toolbox: MATLAB Implementations for Computing and Enhancing Similarity Matrices
%   Proceedings of the 53rd Audio Engineering Society Conference on Semantic Audio, London, 2014.
%
% License:
%     This file is part of 'SM Toolbox'.
%
%     'SM Toolbox' is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 2 of the License, or
%     (at your option) any later version.
%
%     'SM Toolbox' is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with 'SM Toolbox'. If not, see
%     <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [annoSeg, sideinfo] = parseAnnotationFile(filename)
    
    fid = fopen(filename,'r');

    if fid<0
        error(['Cannot open annotation file: ' filename '.']);
    end

    comments = {};
    annoSeg = [];         % convention:  4x1 struct  .start .end .label .type

    onlyStartMode = 0;
    idx = 0;
    while true
        tline = fgetl(fid);
        
        if ~ischar(tline)                   % we have reached the end of file
            break;
            
        elseif isempty(tline)               % we found an empty line (may contains control characters like \n or \t ...)
            1; % do nothing
            
        elseif strcmp(tline(1), '%')        % we found a comment line
            comments{end+1} = tline;

        else                                % we try to parse it
            
            % for the meaning of this regular expression like +, *, or ?
            % refer to help text in REGEXP.           
            myRegExp = '([A-Za-z_]+[\s,]+)?(?<start>\d+\.?\d*[\s,]+)(?<end>\d+\.?\d*[\s,]+)?([\w\:])*(\".*\")?';
            
            myResults = regexp(tline ,myRegExp, 'tokens');
                        
            if ~isempty(myResults)
                myResults   = myResults{:};
                type        = strtrim(myResults{1});
                segmStart   = str2double(strtrim(myResults{2}));
                segmEnd     = str2double(strtrim(myResults{3}));
                label       = strtrim(myResults{4});
                
                if isempty(label)
                    label   = strtrim(myResults{5});
                    label   = strrep(label, '"', '');
                end
            
                if isempty(type)
                    type = '';
                end
                
                if onlyStartMode == 1
                    annoSeg(idx).end = segmStart - eps;
                end
                
                idx = idx + 1;
                annoSeg(idx).start = segmStart;
                annoSeg(idx).end   = segmEnd;
                annoSeg(idx).label = label;
                annoSeg(idx).type  = type;

                if(isnan(segmEnd))
                    onlyStartMode = 1;
                else
                    onlyStartMode = 0;
                end
            end
            
        end

    end
    
    if isnan(annoSeg(idx).end)
        annoSeg(idx) = [];
    end

    fclose(fid);
    
    sideinfo.groundTruth = '';
    sideinfo.groundTruth.filename = filename;
    sideinfo.groundTruth.comments = comments;
    
end

