function MatrixProbability = MatProb( lengthOfMat, ProbDiagnoal, ProbOffDiagonal )
% This function creates a matrix with the same value on the diagonal
% (ProbDiagnoal), and another value for all positions on the off-diagonal.

MatrixProbability = zeros(lengthOfMat,lengthOfMat);

 for i = 1:lengthOfMat
     MatrixProbability(i,:) = [ones(1,i-1)*ProbOffDiagonal , ProbDiagnoal, ones(1, lengthOfMat-i)*ProbOffDiagonal];
 end
 

end

