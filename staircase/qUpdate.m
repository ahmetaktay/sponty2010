function q = qUpdate(q, intensity, response)
% Given a set of contrasts and responses, will create a new quest structure
% function q = qUpdate(q, intensity, response)
    
    for ii=1:length(intensity);
        q = QuestUpdate(q, log10(intensity(ii)), response(ii));
    end
    
