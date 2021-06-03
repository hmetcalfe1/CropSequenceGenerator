function P = getP(...
    probmat,numcrops,mycrops,field,year,addCropRules...
    ,potcounter,beetcounter,osrcounter,grass1counter,whcounter,maizecounter,grass2counter...
    ,potcropnum,beetcropnum,osrcropnum,grass1cropnum,whcropnum,maizecropnum,grass2cropnum,swcropnum...
    ,whmax,maizemax,grass2max...
)
    %Extract only the row of the probability matrix for the last crop - applying any crop rules
    Pfull=probmat; %Store the probmat in a temporary Pfull so we can change it
    %Alter the probability matrix to reflect any rules currently in place
    
    if addCropRules
        if potcounter(field,1)>0 %if we are not allowed to grow potatoes remove them from the probability matrix
            Pfull=reduceprobmat(Pfull,potcropnum,numcrops);
        end
        if beetcounter(field,1)>0 %if we are not allowed to grow beet remove them from the probability matrix
            Pfull=reduceprobmat(Pfull,beetcropnum,numcrops);
        end
        if osrcounter(field,1)>0 %if we are not allowed to grow osr remove them from the probability matrix
            Pfull=reduceprobmat(Pfull,osrcropnum,numcrops);
        end
        if grass1counter(field,1)>0 %if we are not allowed to grow grass1 remove them from the probability matrix
            Pfull=reduceprobmat(Pfull,grass1cropnum,numcrops);
        end
        if whcounter(field,1)>=whmax %if we are not allowed to grow wheat remove them from the probability matrix
            Pfull=reduceprobmat(Pfull,whcropnum,numcrops);
            Pfull=reduceprobmat(Pfull,swcropnum,numcrops);
        end
        if maizecounter(field,1)>=maizemax %if we are not allowed to grow maize remove them from the probability matrix
            Pfull=reduceprobmat(Pfull,maizecropnum,numcrops);
        end
        if grass2counter(field,1)>=grass2max %if we are not allowed to grow grass2 remove them from the probability matrix
            Pfull=reduceprobmat(Pfull,grass2cropnum,numcrops);
        end
    end
    lastcrop=mycrops(field,year); %find what the previous crop was
    P=Pfull(lastcrop,:); %extract only that row of the probability matrix for crop transitions
end
