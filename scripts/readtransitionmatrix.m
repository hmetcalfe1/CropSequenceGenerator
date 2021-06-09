function probmat = readtransitionmatrix(cropNames, nuts_soil, numcrops, file) %file=tmFile
    %read in the transition matrix for the chosen nuts_soil region. 
    %Note these are probabilities of going from rows to columns.
    
    path = strcat(fileparts(pwd),"\probabilities\");
    suffix = ".txt";
    probmat = readtable(strcat(path, file, nuts_soil, suffix));   
    probmat = outerjoin(cropNames,probmat,'MergeKeys',true,'LeftKeys','cropNames','RightKeys','crop');
    probmat = rows2vars(probmat, 'VariableNamesSource','cropNames_crop');
    probmat = outerjoin(cropNames,probmat,'MergeKeys',true,'LeftKeys','cropNames','RightKeys','OriginalVariableNames');
    probmat = rows2vars(probmat, 'VariableNamesSource','cropNames_OriginalVariableNames');
    probmat = removevars(probmat,{'OriginalVariableNames'});
        
    probmat = table2array(probmat);
    probmat(isnan(probmat)) = 0;
    
    %check each row sums to one - if not adjust
    probmattotal=sum(probmat,2);
    for i=1:numcrops %for each row
        for j=1:numcrops %for each column/probability
            if probmattotal(i,1)>0 %if rowSum>0 rescale (even if it is correctly = 1)
                probmat(i,j)=probmat(i,j)/probmattotal(i,1); 
            else
                probmat(i,j)=0;
            end
        end
    end
end