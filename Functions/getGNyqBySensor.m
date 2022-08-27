function GNyq = getGNyqBySensor(sensor, n_band, is_XS)

if is_XS
    switch sensor
        case 'QB' 
            GNyq = [0.34 0.32 0.30 0.22]; % Band Order: B,G,R,NIR
        case 'IKONOS'
            GNyq = [0.26,0.28,0.29,0.28]; % Band Order: B,G,R,NIR
        case {'GeoEye1','WV4'}
            GNyq = [0.23,0.23,0.23,0.23]; % Band Order: B,G,R,NIR
        case 'WV2'
            GNyq = [0.35 .* ones(1,7), 0.27];
        case {'WV3','WV3_4bands'}   % from reg GLP
            GNyq = [0.325 0.355 0.360 0.350 0.365 0.360 0.335 0.315];
            if strcmp(sensor,'WV3_4bands')
                GNyq = GNyq([2 3 5 7]);    
            end   
        case 'GF2'
            %GNyq = [0.26,0.21,0.2,0.18]; % 1
            %GNyq = [0.37,0.18,0.22,0.17]; % 2
            %GNyq = [0.26,0.22,0.21,0.15]; % 3
            %GNyq = [0.2,0.2,0.2,0.2]; % 4
            %GNyq = [0.3,0.3,0.3,0.3]; % 5
            GNyq = [0.25,0.21,0.2,0.15]; % 6
        case 'none'
            GNyq = 0.29 .* ones(1,n_band);
        otherwise
            warning('No matched tag for MTF of XS. Using default GNyq');
            GNyq = 0.29 .* ones(1,n_band);
    end
else
    switch sensor
        case 'QB' 
            GNyq = 0.15; 
        case 'IKONOS'
            GNyq = 0.17;
        case 'GeoEye1'
            GNyq = 0.16;
        case 'WV2'
            GNyq = 0.11;
        case 'GF2'
            GNyq = 0.05;%!!!!!!!!!!!!!!!!!
        case 'none'
            GNyq = 0.15;
        otherwise
            warning('No matched tag for MTF of PAN. Using default GNyq');
            GNyq = 0.15;          
    end
end

if length(GNyq) ~= n_band
    warning('Band number mismatch!');
    GNyq = GNyq(:,1:n_band);
end