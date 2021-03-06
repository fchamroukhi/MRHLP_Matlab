function model = init_regression_param_MRHLP(X, y, K, type_variance, try_EM)
% function param = init_regression_param(X, y, K, type_variance, try_EM)
% initializes the regressions parameters for the MRHLP model: the
% regressions coefficients vector and the variance, for each component.
%
% Inputs :
%
%        X : a p-degreee polynomial regression design matrix (dim = [m x(p+1)])
%        y : a multivariate signal or time series (dim = [m x d])
%        K : number of hidden regimes (segments)
%
% Outputs :
%         param : initial regression parameters: structure with the fields:
%         1. betak : Matrix of K vectors of regression coeffcients: dim = [(p+1)x K]
%         2. sigmak: the variance of earch regime (variance of y given z=k) sigma{k} = sigma^2_k: cector of dimension K
%
%
%
% Faicel Chamroukhi, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(type_variance,'homoskedastic')
    homoskedastic = 1;
else
    homoskedastic = 0;
end
[m, P] = size(X);
%[~, d] = size(y);


if  try_EM ==1% uniform segmentation into K contiguous segments, and then a regression
    zi = round(m/K)-1;
    
    s=0;% if homoskedastic
    for k=1:K
        yk = y((k-1)*zi+1:k*zi, :);
        Xk = X((k-1)*zi+1:k*zi,:);
        model.betak{k} = inv(Xk'*Xk)*Xk'*yk;%regress(yk,Xk); % for a use in octave, where regress doesnt exist
        muk = Xk*model.betak{k};
        sk = (yk-muk)'*(yk-muk);
        if homoskedastic
            s = s+sk;
            model.sigmak = s/m;%cov(y);
        else
            model.sigmak{k} = sk/length(yk);% sk/length(yk);
        end
    end
    
else % random segmentation into contiguous segments, and then a regression
    Lmin= P+1;%minimum length of a segment %10
    tk_init = zeros(K,1);
    tk_init(1) = 0;
    K_1=K;
    for k = 2:K
        K_1 = K_1-1;
        temp = tk_init(k-1)+Lmin:m-K_1*Lmin;
        ind = randperm(length(temp));
        tk_init(k)= temp(ind(1));
    end
    tk_init(K+1) = m;
    
    s=0;
    for k=1:K
        i = tk_init(k)+1;
        j = tk_init(k+1);
        yk = y(i:j, :);%y((k-1)*zi+1:k*zi, :);
        Xk = X(i:j,:);%X((k-1)*zi+1:k*zi,:);
        model.betak{k} = inv(Xk'*Xk)*Xk'*yk;%regress(yk,Xk); % for a use in octave, where regress doesnt exist
        
        muk = Xk*model.betak{k};
        sk= (yk-muk)'*(yk-muk);
        if homoskedastic
            s = s+sk;
            model.sigmak = s/m;%1;%var(y);
        else
            model.sigmak{k} =  sk/length(yk);
        end
    end
    
    
end
end


