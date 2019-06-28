function [D]= get_distance_matrix(songa, songb, pitch_or_rhythm)


% longer to shorter

if size(songa,1) < size(songb,1)
    song_a=songb;
    song_b=songa;
else
    song_a=songa;
    song_b=songb;

end


%-1 -> pitch to interval
s_seg=min(size(song_a,1),size(song_b,1))-1; 
%no calculation on interval 1 to 1
D=zeros(size(song_a,1)-3, size(song_b,1)-3); 

D(:,:)=100;   


switch pitch_or_rhythm
    case 1
        display('getting distance matrix for pitch..')
        
        for i=3:s_seg
            D(1:size(song_a,1)-i,i-2)=segments_pitch(song_a,song_b, i);            
        end
        

    case 2
        display('getting distance matrix for rhythm..')
        for i=3:s_seg
            D(1:size(song_a,1)-i,i-2)=segments_rhythm(song_a,song_b, i);            
        end        
end

D=D';
get_graph(D, pitch_or_rhythm); %get graph

end






%% Pitch

function D= segments_pitch(song_a, song_b, seg_win_size)
%% get pitch
pc=song_a(:,4);
pc_b=song_b(:,4);

   
%% convert to interval 
resolution = 1;
seg_hop_size=1;

interval= zeros(length(pc)-1,1);
interval_b=zeros(length(pc_b)-1,1);
interv_size = floor((length(interval)-seg_win_size)/seg_hop_size+1);
interv_size_b=floor((length(interval_b)-seg_win_size)/seg_hop_size+1);
interval_threshold=12; 

% interval a
for i=1:length(interval)
    value = pc(i+1)-pc(i);
    if value >= interval_threshold
        value = interval_threshold;
    elseif value <= -interval_threshold
        value = -interval_threshold;
    end
    if value < 0 
        value_IR= -ceil((abs(value))/resolution);
    else
        value_IR=ceil((abs(value))/resolution);
    end
        
    interval(i)= value_IR;
end


    %interval b
for i=1:length(interval_b)
    value = pc_b(i+1)-pc_b(i);
    if value >= interval_threshold
        value = interval_threshold;
    elseif value <= -interval_threshold
        value = -interval_threshold;
    end
    if value < 0 
        value_IR= -ceil((abs(value))/resolution);
    else
        value_IR=ceil((abs(value))/resolution);
    end
    interval_b(i)= value_IR;
end

%% get minimum distance

for i = 1:interv_size
    hop_start = 1+seg_hop_size*(i-1);
    interval_hopped_a_tmp = interval(hop_start:hop_start+seg_win_size-2);
    D_tmp=0;
    
    for seg_b=1:interv_size_b
        hop_start = 1+seg_hop_size*(seg_b-1);
        interval_hopped_b_tmp = interval_b(hop_start:hop_start+seg_win_size-2);
    
        D_tmp(seg_b)=EditDistance(interval_hopped_a_tmp', interval_hopped_b_tmp');
       
    
    end
    min_v=min(D_tmp);
    max_v=(seg_win_size-1)*2;
    D_final(i)=min_v/max_v;

end
    D=D_final;
end



%% Rhythm

function D= segments_rhythm(song_a, song_b, seg_win_size)   
%% get beat

beat=song_a(:,7);
beat_b=song_b(:,7);

    

%% convert to ratio

rhythm_ratio= zeros(length(beat)-1,1);
rhythm_ratio_b=zeros(length(beat_b)-1,1);
R_interval= zeros(length(beat)-1,1);
R_interval_b=zeros(length(beat_b)-1,1);
seg_hop_size=1;
interv_size = floor((length(rhythm_ratio)-seg_win_size)/seg_hop_size+1);
interv_size_b=floor((length(rhythm_ratio_b)-seg_win_size)/seg_hop_size+1);


for i = 1:length(rhythm_ratio)
    rhythm_ratio(i)=beat(i+1)/beat(i);
end

acc = 0.5;
R_interval = round(rhythm_ratio/acc)*acc;
R_interval(R_interval > 4) = 4;

for i = 1:length(rhythm_ratio_b)
    rhythm_ratio_b(i)=beat_b(i+1)/beat_b(i);
end
R_interval_b=round(rhythm_ratio_b/acc)*acc;
R_interval_b(R_interval_b > 4) = 4;


%% get minimum distance

for i = 1:interv_size
    count_s=0;
    count_t=0;
    hop_start = 1+seg_hop_size*(i-1);
    interval_hopped_a_tmp = R_interval(hop_start:hop_start+seg_win_size-2);
    
    D_tmp=0;
    for seg_b=1:interv_size_b
        hop_start = 1+seg_hop_size*(seg_b-1);
        interval_hopped_b_tmp = R_interval_b(hop_start:hop_start+seg_win_size-2);
    
        D_tmp(seg_b)=EditDistance(interval_hopped_a_tmp, interval_hopped_b_tmp);

    end
    min_v=min(D_tmp);
    max_v=(seg_win_size-1)*2;
    D_final(i)=min_v/max_v;
end
    D=D_final;
end









%% Distance measure


function [V,v] = EditDistance(string1,string2)

m=length(string1);
n=length(string2);
v=zeros(m+1,n+1);
for i=1:1:m
    v(i+1,1)=i;
end
for j=1:1:n
    v(1,j+1)=j;
end
for i=1:m
    for j=1:n
        if (string1(i) == string2(j))
            v(i+1,j+1)=v(i,j);
        else
            v(i+1,j+1)=2+min(min(v(i+1,j),v(i,j+1)),v(i,j));
        end
    end
end
V=v(m+1,n+1);
end



%% Get graph

function D_graph=get_graph(D, pitch_or_rhythm)

D(:,:)=1-D(:,:);
y=size(D,1);
x=size(D,2);
D_inversed=zeros(y,x);
D_for_graph=zeros(y,x);
D_for_graph(:,:)=-1;
 
for i=1:y
    D_inversed(y-i+1,:)=D(i,:);
end

for i=1:y
    x_index=round((x-(x-y)-i)/2)+1;
    x_length=x-y+i;
    D_for_graph(i,x_index:x_index+x_length-1)= D_inversed(i,1:x_length);
end

figure()
clims = [0 1];
imagesc(D_for_graph,clims)
yticklabels = 3:5:size(D_for_graph,1)+3;
yticks = linspace(1, size(D_for_graph, 1), numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', flipud(yticklabels(:)))

h=colorbar;
switch pitch_or_rhythm 
    case 1
        colormap(flipud(hot))
        set(get(h,'title'),'string','Pitch Similarity');
    case 2
        mymap= [1,1,1;0.996923089027405,0.999230742454529,0.969230771064758;0.993846178054810,0.998461544513702,0.938461542129517;0.990769207477570,0.997692286968231,0.907692313194275;0.987692296504974,0.996923089027405,0.876923084259033;0.984615385532379,0.996153831481934,0.846153855323792;0.981538474559784,0.995384633541107,0.815384626388550;0.978461563587189,0.994615375995636,0.784615397453308;0.975384593009949,0.993846178054810,0.753846168518066;0.972307682037354,0.993076920509338,0.723076939582825;0.969230771064758,0.992307722568512,0.692307710647583;0.966153860092163,0.991538465023041,0.661538481712341;0.963076949119568,0.990769267082214,0.630769252777100;0.960000038146973,0.990000009536743,0.600000023841858;0.956923067569733,0.989230751991272,0.569230794906616;0.953846156597138,0.988461554050446,0.538461565971375;0.950769245624542,0.987692296504974,0.507692337036133;0.947692334651947,0.986923098564148,0.476923078298569;0.944615423679352,0.986153841018677,0.446153849363327;0.941538453102112,0.985384643077850,0.415384620428085;0.938461542129517,0.984615385532379,0.384615391492844;0.935384631156921,0.983846187591553,0.353846162557602;0.932307720184326,0.983076930046082,0.323076933622360;0.929230809211731,0.982307732105255,0.292307704687119;0.926153838634491,0.981538474559784,0.261538475751877;0.923076927661896,0.980769276618958,0.230769231915474;0.920000016689301,0.980000019073486,0.200000002980232;0.871578991413117,0.963684201240540,0.189473688602448;0.823157906532288,0.947368443012238,0.178947374224663;0.774736881256104,0.931052625179291,0.168421059846878;0.726315796375275,0.914736866950989,0.157894745469093;0.677894771099091,0.898421049118042,0.147368416190147;0.629473686218262,0.882105290889740,0.136842101812363;0.581052660942078,0.865789473056793,0.126315787434578;0.532631576061249,0.849473714828491,0.115789473056793;0.484210520982742,0.833157896995544,0.105263158679008;0.435789495706558,0.816842138767242,0.0947368443012238;0.387368440628052,0.800526320934296,0.0842105299234390;0.338947385549545,0.784210562705994,0.0736842080950737;0.290526330471039,0.767894744873047,0.0631578937172890;0.242105260491371,0.751578986644745,0.0526315793395042;0.193684220314026,0.735263168811798,0.0421052649617195;0.145263165235519,0.718947410583496,0.0315789468586445;0.0968421101570129,0.702631592750549,0.0210526324808598;0.0484210550785065,0.686315834522247,0.0105263162404299;0,0.670000016689301,0;0.00231481483206153,0.632777810096741,0;0.00462962966412306,0.595555543899536,0;0.00694444449618459,0.558333337306976,0;0.00925925932824612,0.521111130714417,0;0.0115740746259689,0.483888894319534,0;0.0138888889923692,0.446666687726975,0;0.0162037033587694,0.409444451332092,0;0.0185185186564922,0.372222244739532,0;0.0208333339542151,0.335000008344650,0;0.0231481492519379,0.297777771949768,0;0.0254629645496607,0.260555565357208,0;0.0277777779847384,0.223333343863487,0;0.0300925932824612,0.186111122369766,0;0.0324074067175388,0.148888885974884,0;0.0347222238779068,0.111666671931744,0;0.0370370373129845,0.0744444429874420,0;0.0393518544733524,0.0372222214937210,0;0.0416666679084301,0,0];
        colormap(mymap)
        set(get(h,'title'),'string','Rhythm Similarity');
end

caxis([0,1])


end
