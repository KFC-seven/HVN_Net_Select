function [Hxy,LOS] = getH(mL,mN,beta,r)
    %根据概率判断本次通信环境是LOS还是NLOS
    plos=exp(-beta*r);
    if plos>1 || plos<0
        disp(['[Error]plos=',num2str(plos)]);
    end
    pnlos=1-plos;

    t = rand();
    if t<plos
        LOS=true;
        %每个无线信道都经历独立的Nakagami-m衰落
        Hxy=gamrnd(mL,1/mL);        
    else
        LOS=false;
        Hxy=gamrnd(mN,1/mN);
    end
end
