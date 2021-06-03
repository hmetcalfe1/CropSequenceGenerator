%% Simulation of potential cropping sequences for the UK based on transition matrices specific to a given subregion

%Regions are defined as NUTS1 (C-M)
%Subregions are categoried by soil clay content as heavy(H), medium(M) or light(L)
%This code will output realistic cropping sequences for the chosen subregion for a chosen number of fields over a chosen number of years

clc
clear

%% User Set up
% Information on how many fields, years and crops to simulate, which region to simulate, and whether to include permanent grassland.

addCropRules = false;

if addCropRules
    cropRuleStr = "_addedCropRules";
    ssFile = "steadystates-permagrass-sample+grassRule_UK"
    tmFile = "probabilities-permagrass-sample+grassRule_UK"    
    cropNames = {   'be'    'fb'    'gr1'   'gr2'   'ma'    'or'    'ot'	'po'	'sb'	'sw'	'wb'	'ww'}'; % how many different crops are there
    cropmat = [     1,      2,      3,      4,      5,      6,      7,      8,      9,      10,     11      12]; %Each crop is assigned a number    
else
    cropRuleStr = "_noCropRules";
    ssFile = "steadystates-permagrass-sample_UK"
    tmFile = "probabilities-permagrass-sample_UK"    
    cropNames = {   'be'    'fb'    'gr'   'ma'    'or'    'ot'	'po'	'sb'	'sw'	'wb'	'ww'}'; % how many different crops are there
    cropmat = [     1,      2,      3,      4,      5,      6,      7,      8,      9,      10,     11]; %Each crop is assigned a number        
end

numfields=1000; %100000; % how many fields to simulate
numyears=200; %1; % how many years to predict crops for

numcrops=size(cropNames,1);
cropNames = table(cropNames);

nuts = ["C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"];
soils = ["H" "M" "L"];

for nut = nuts %nut="D"
    for soil = soils %soil="H"
        
        nuts_soil = strcat(nut,"_",soil)
        
        if nuts_soil ~= "D_H"
            %% Read  in data
            
            % Read in the initial frequencies and the transition matrices
            initialfreq = readsteadystates(cropNames, nuts_soil, ssFile); %We initialise the fields with steady state propotions
            initialfreq=initialfreq'; %transpose
            
            % read in the probability matrix of changing from one crop (rows) to another (columns)
            probmat = readtransitionmatrix(cropNames, nuts_soil, numcrops, tmFile);
            
            %% Set up Rules
            % Set up crop rules limiting frequency and continuous growth of certain crops
            
            %Limit on crop frequency----
            
            %Potato rule - maximum 1 crop in 4 years
            potcounter=zeros(numfields,1); %setup a vector that will count down to the next time potatoes are allowed
            if addCropRules                    
                potcropnum=8; %which crop number is potatoes
                potgap=3; %how many years to leave between potatoes?
            else
                potcropnum=7; %which crop number is potatoes
                potgap=0; %how many years to leave between potatoes?
            end
            
            %Beet rule - maximum 1 crop in 4 years
            beetcropnum=1; %which crop number is Beet
            beetcounter=zeros(numfields,1); %setup a vector that will count down to the next time Beet are allowed
            if addCropRules
                beetgap=3; %how many years to leave between Beet?
            else
                beetgap=0; %how many years to leave between Beet?
            end
            
            %OSR rule - maximum 1 crop in 4 years
            osrcounter=zeros(numfields,1); %setup a vector that will count down to the next time OSR are allowed
            if addCropRules
                osrcropnum=6; %which crop number is OSR
                osrgap=3; %how many years to leave between OSR?
            else
                osrcropnum=5; %which crop number is OSR
                osrgap=0; %how many years to leave between OSR?
            end
            
            %grass1 rule - leave 2 year gap before planting grass 1 after a grass 2
            grass1cropnum=3; %which crop number is grass1
            grass1counter=zeros(numfields,1); %setup a vector that will count down to the next time OSR are allowed
            if addCropRules
                grass1gap=2; %how many years to leave between grass leys?
            else
                grass1gap=0; %how many years to leave between grass leys?
            end
            
            % Limit on continuous cropping----
            
            %Wheat rule - no more than 2 consecutive
            whcounter=zeros(numfields,1); %setup a vector that will count down how many wheat crops we have had
            if addCropRules
                whcropnum=12; %which crop number is Winter Wheat
                swcropnum=10; %which crop number is Spring Wheat
                whmax=2; %how many consecutive wheat crops are allowed?
            else
                whcropnum=11; %which crop number is Winter Wheat
                swcropnum=9;  %which crop number is Spring Wheat              
                whmax=inf; %how many consecutive wheat crops are allowed?
            end
            
            %Maize rule - no more than 2 consecutive
            maizecounter=zeros(numfields,1); %setup a vector that will count down how many wheat crops we have had
            if addCropRules
                maizecropnum=5; %which crop number is Maize
                maizemax=5; %how many consecutive maize crops are allowed?
            else
                maizecropnum=4; %which crop number is Maize
                maizemax=inf; %how many consecutive maize crops are allowed?
            end
            
            %Grass2 rule - no more than 3 consecutive (4 including Grass1)
            grass2counter=zeros(numfields,1); %setup a vector that will count down how many wheat crops we have had
            if addCropRules
                grass2cropnum=4; %which crop number is grass2
                grass2max=3; %how many consecutive grass2 crops are allowed?
            else
                grass2cropnum=3; %which crop number is grass2
                grass2max=inf; %how many consecutive grass2 crops are allowed?
            end
            
            %% Initialise the fields according to the initialfreq vector
            fieldsset=0; %counter for how many fields have been initialised
            
            for crop=1:numcrops %Go through each crop tyoe
                cropfields=round(numfields*initialfreq(1,crop)); %find out how many fields should be in that crop type based on the initialfreq
                
                if fieldsset+cropfields>numfields %if there are not enough fields left that have not yet been assigned a croptype
                    cropfields=numfields-fieldsset; %change the number of fields for that crop type to the number of fields that are left
                end
                
                mycrops(fieldsset+1:fieldsset+1+cropfields,1)=crop; %assign fields sequentially to the crop type
                fieldsset=fieldsset+cropfields; %Add the number of fields assigned to this crop to the counter
            end % End of going through each crop type
            
            %above code seems to add an extra 12 entry at the end.
            if sum(mycrops(:)==numcrops) == cropfields+1
               mycrops = mycrops(1:(end-1));
            end
            
            if fieldsset<numfields %if at the end we have not assigned all of the fields to a croptype
                notset=numfields-fieldsset; %find out how many have not been set
                for i=1:notset %Go through the fields that have not been set
                    
                    %assign those fields to a croptype according tio the initial freq
                    mycrops(numfields-notset+1,1) = cropmat(find(rand<cumsum(initialfreq),1,'first')); 
                    
                end%End of going through the fields that have not been set
            end
            
            if addCropRules
                %Check if any of the initialised fields should have a rule applied to them and set up the counters
                for field=1:numfields %Go through each field
                    
                    if  mycrops(field,1)==potcropnum %If the initialcrop is potatoes
                        potcounter(field,1)=potgap; %Start the potcounter at the number of years between potato crops
                    end
                    
                    if  mycrops(field,1)==beetcropnum %If the initialcrop is beet
                        beetcounter(field,1)=beetgap; %Start the beetcounter at the number of years between beet crops
                    end
                    
                    if  mycrops(field,1)==osrcropnum %If the initialcrop is osr
                        osrcounter(field,1)=osrgap; %Start the osrcounter at the number of years between osr crops
                    end
                    
                    if  mycrops(field,1)==grass2cropnum %If the initialcrop is grass2
                        grass1counter(field,1)=grass1gap; %Start the grass1counter at the number of years between grass crops
                    end
                    
                    if mycrops(field,1)==whcropnum || mycrops(field,1)==swcropnum %If the initialcrop is wh
                        whcounter(field,1)=1; %Start the whcounter at 1
                    end
                    
                    if mycrops(field,1)==maizecropnum %If the initialcrop is maize
                        maizecounter(field,1)=1; %Start the maizecounter at 1
                    end
                    
                    if mycrops(field,1)==grass2cropnum %If the initialcrop is maize
                        grass2counter(field,1)=1; %Start the maizecounter at 1
                    end
                    
                end %End of going through each field
            end
            
            %calculate the frequency of crops grown in the first year (note this should match the initialfreq
            cropfreq=zeros(numcrops,numyears);
            for crop=1:numcrops %Go through each crop
                cropfreq(crop,1) = sum(mycrops(:,1) == crop);
            end %End of going through each crop
            
            %% Simulate Crop Sequences------------------------------------------------------------
            %use the transition matrix to chose the next crop according to the probabilites
            for year=1:numyears-1 %Go through each year
                
                for field=1:numfields %Go through each field
                    %P is the row of the probability matrix for the current crop with probabilites adjusted according to any pertinent crop rules
                    P = getP(...
                        probmat,numcrops,mycrops,field,year,addCropRules...
                        ,potcounter,beetcounter,osrcounter,grass1counter,whcounter,maizecounter,grass2counter...
                        ,potcropnum,beetcropnum,osrcropnum,grass1cropnum,whcropnum,maizecropnum,grass2cropnum,swcropnum...
                        ,whmax,maizemax,grass2max...
                    );
                    if any(isnan(P),'all') %If the crop rules have broken the 
                        %probability matrix go back to the initial frequencies but remove any crops not allowed
                        P = resetP(...
                            initialfreq,field,numcrops,addCropRules...
                            ,potcounter,beetcounter,osrcounter,grass1counter,whcounter,maizecounter,grass2counter...
                            ,potcropnum,beetcropnum,osrcropnum,grass1cropnum,whcropnum,maizecropnum,grass2cropnum,swcropnum...
                            ,whmax,maizemax,grass2max...
                        );
                    end
                    mycrops(field,year+1) = cropmat(find(rand<cumsum(P),1,'first')); %choose a crop for this year based on the probability matrix
                    
                    if addCropRules
                        %Set any new counters based on the chosen crop or move along previously set counters
                        if mycrops(field,year+1)==potcropnum %if we draw potatoes
                            potcounter(field,1)=potgap; %set the potcounter for that field to the gap
                        else
                            potcounter(field,1)=max(0,potcounter(field,1)-1); %reduce the potato counter by 1 but stop at zero
                        end
                    
                        if mycrops(field,year+1)==beetcropnum %if we draw beet
                            beetcounter(field,1)=beetgap; %set the beetcounter for that field to gap
                        else
                            beetcounter(field,1)=max(0,beetcounter(field,1)-1); %reduce the beet counter by 1 but stop at zero
                        end
                    
                        if mycrops(field,year+1)==osrcropnum %if we draw osr
                            osrcounter(field,1)=osrgap; %set the osrcounter for that field to gap
                        else
                            osrcounter(field,1)=max(0,osrcounter(field,1)-1); %reduce the osr counter by 1 but stop at zero
                        end
                    
                        if mycrops(field,year+1)==whcropnum || mycrops(field,year+1)==swcropnum %if we draw wheat
                            whcounter(field,1)=whcounter(field,1)+1; %add 1 onto the wheatcounter
                        else
                            whcounter(field,1)=0; %reset the wheat counter to 0
                        end
                    
                        if mycrops(field,year+1)==maizecropnum %if we draw maize
                            maizecounter(field,1)=maizecounter(field,1)+1; %add 1 onto the maizecounter
                        else
                            maizecounter(field,1)=0; %reset the maize counter to 0
                        end
            
                        if mycrops(field,year+1)==grass2cropnum %if we draw grass2
                            grass1counter(field,1)=grass1gap; %set the grass1counter for that field to gap
                            grass2counter(field,1)=grass2counter(field,1)+1; %add 1 onto the grass2counter
                        else
                            grass1counter(field,1)=max(0,grass1counter(field,1)-1); %reduce the grass1 counter by 1 but stop at zero
                            grass2counter(field,1)=0; %reset the grass2 counter to 0
                        end
                    end
                    
                end %End of going through each field
            
                %calculate the frequency of crops grown in this year
                for crop=1:numcrops %Go through each crop
                    cropfreq(crop,year+1) = sum(mycrops(:,year+1) == crop);
                end %End of going through each crop
            
            end %End of going through each year
            
            %% Save the generated crop sequences to a csv file
            filename=sprintf('%s_croplists_%iyr_%irun%s.csv',nuts_soil, numyears, numfields, cropRuleStr);
            csvwrite(strcat(fileparts(pwd),"\data\cropLists\",filename),mycrops)
            
        end
    end
end
