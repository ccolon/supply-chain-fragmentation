function [a0, a1, a2] = quadraticFit(Y, X)  

    XMat = [ones(length(Y),1) X X.^2];
    
    
%     if abs(det(XMat' * XMat)) <= 1e-5
%         XMat
%         Y
%     end
    
    A = (XMat' * XMat) \ XMat' * Y;
    
    a0 = A(1);
    a1 = A(2);
    a2 = A(3);
    
end