function redprobmat = reduceprobmat(probmat,nocropnum,numcrops) 
    %create a reduced probability matrix from the starting probability matrix 
    %by removing the crop number speciifed by nocropnum
    redprobmat=probmat; %copy the probability matrix
    redprobmat(:,nocropnum)=0;%set all probabilities for the given crop to zero
    nocropprobtotal=sum(redprobmat,2);
    for i=1:numcrops
        for j=1:numcrops
            redprobmat(i,j)=redprobmat(i,j)/nocropprobtotal(i,1);
        end
    end
end