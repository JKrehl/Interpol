export combine_coeffs, combine_indices

function combine_coeffs(coeffs)
	if length(coeffs)==1
		return coeffs
	elseif length(coeffs)==2
		return [:($x * $y) for x in coeffs[1] for y in coeffs[2]]
	else
		return combine_coeffs([coeffs[1], combine_coeffs(coeffs[2:end])])
	end
end

function combine_indices(indices)
	if length(indices)==1
		return indices
	elseif length(indices)==2
		return [(x..., y...) for x in indices[1] for y in indices[2]]
	else
		return combine_indices([indices[1], combine_indices(indices[2:end])])
	end
end
