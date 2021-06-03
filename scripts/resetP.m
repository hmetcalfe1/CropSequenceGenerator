function P = resetP(...
    initialfreq,field,numcrops, potcounter,beetcounter,osrcounter,grass1counter,whcounter,maizecounter,...
    grass2counter,potcropnum,beetcropnum,osrcropnum,grass1cropnum,whcropnum,maizecropnum,grass2cropnum,whmax,maizemax,grass2max...
)
    P=initialfreq;
    if potcounter(field,1)>0 %if we are not allowed to grow potatoes remove them from the probability matrix
        P(potcropnum)=0;
    end
    if beetcounter(field,1)>0 %if we are not allowed to grow beet remove them from the probability matrix
        P(beetcropnum)=0;
    end
    if osrcounter(field,1)>0 %if we are not allowed to grow osr remove them from the probability matrix
        P(osrcropnum)=0;
    end
    if grass1counter(field,1)>0 %if we are not allowed to grow grass1 remove them from the probability matrix
        P(grass1cropnum)=0;
    end
    if whcounter(field,1)>=whmax %if we are not allowed to grow wheat remove them from the probability matrix
        P(whcropnum)=0;
    end
    if maizecounter(field,1)>=maizemax %if we are not allowed to grow maize remove them from the probability matrix
        P(maizecropnum)=0;
    end
    if grass2counter(field,1)>=grass2max %if we are not allowed to grow maize remove them from the probability matrix
        P(grass2cropnum)=0;
    end
    Ptotal=sum(P);
    for i=1:numcrops %Go through each crop
        P(i)=P(i)/Ptotal;%rescale the other propoertions
    end %End of going through each crop
end