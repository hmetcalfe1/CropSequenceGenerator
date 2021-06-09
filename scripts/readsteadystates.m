function initfreq = readsteadystates(cropNames, nuts_soil, file) %nuts_soil = "C_H"; file=ssFile
    %These are the steady states for each subregion (NUTS1_soiltype) calculated
    %These are used to provide the initial frequency of each crop
    path = strcat(fileparts(pwd),"\probabilities\");
    suffix = ".txt";
    initfreq = readtable(strcat(path, file, nuts_soil, suffix)); %read file
    initfreq = outerjoin(cropNames,initfreq,'MergeKeys',true,'LeftKeys','cropNames','RightKeys','crop'); %add crops not in file
    initfreq = initfreq.prop;
    initfreq(isnan(initfreq)) = 0;
end