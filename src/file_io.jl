"""
    read_poi( filepath::String ) :: POI{Rational{Int64}}

Creates a `POI` struct by parsing the provided `.poi` file. A `DomainError` is thrown
if argument `filepath` does not end with the `.poi` extension.
"""
function read_poi(filepath :: String)::POI{Rational{Int64}}
    if !(occursin(r"\.poi$", filepath))
        throw(DomainError(filepath, "filepath does not end in extension `.poi`."))
    end

    open(filepath) do file
        lines = readlines(file)

        # initializing mutable variables
        current_section = ""
        dim = 0

        # vertices and arrays will be accumulated
        conv_section_vertices = []
        cone_section_rays = []

        # reading file line by line
        for line in lines
            # .poi files are headed with DIM = <num_dimensions>
            dim_match = match(r"^DIM = (\d+)$",line)
            if dim_match != nothing
                dim = parse(Int64,dim_match.captures[1])
            end

            if occursin(r"CONV_SECTION", line)
                current_section = "CONV_SECTION"
            elseif occursin(r"CONE_SECTION", line)
                current_section = "CONE_SECTION"
            end

            # if line contains a vertex/ray
            if occursin(r"^(\(\s*\d+\))?(\s*([+-])?\s*\d+)+", line)
                digit_matches = collect(eachmatch(r"\s*([+-])?\s*(\d+)(?!\))(?:/(\d+))?", line))
                num_matches = length(digit_matches)

                # map makes col vectors reshape to be row vectors
                point = reshape( map(regex -> begin
                    sign = (regex.captures[1] === nothing) ? "+" : regex.captures[1]
                    num = parse(Int64, sign*regex.captures[2])
                    den = (regex.captures[3] === nothing) ? 1 : parse(Int64, regex.captures[3])

                    Rational(num, den)
                end, digit_matches), (1,num_matches))

                if current_section == "CONV_SECTION"
                    push!(conv_section_vertices, point)
                elseif current_section == "CONE_SECTION"
                    push!(cone_section_rays, point)
                end
            end

            if occursin(r"END", line)
                break
            end
        end

        null_matrix = Array{Rational{Int64}}(undef, 0, 0)
        vertices = (length(conv_section_vertices) == 0) ? null_matrix : vcat(conv_section_vertices...)
        rays = (length(conv_section_vertices) == 0) ? null_matrix : vcat(cone_section_rays...)

        POI(vertices=vertices, rays=rays)
    end
end

"""
    read_ieq( filepath::String ) :: IEQ{Rational{Int64}}

Creates an `IEQ` struct by parsing the provided `.ieq` file. A `DomainError` is thrown
if argument `filepath` does not end with the `.ieq` extension.
"""
function read_ieq(filepath::String)::IEQ{Rational{Int64}}
    if !(occursin(r"\.ieq$", filepath))
        throw(DomainError(filepath, "filepath does not end in extension `.ieq`."))
    end

    open(filepath) do file
        lines = readlines(file)

        # initializing mutable variables
        current_section = ""
        dim = 0

        # vertices and arrays will be accumulated
        inequalities = []
        equalities  = []
        upper_bounds = []
        lower_bounds = []
        elimination_order = []
        valid = []

        for line in lines
            # .ieq files are headed with DIM = <num_dimensions>
            dim_match = match(r"^DIM = (\d+)$",line)
            if dim_match != nothing
                dim = parse(Int64,dim_match.captures[1])
            end

            if occursin(r"LOWER_BOUNDS", line)
                current_section = "LOWER_BOUNDS"
            elseif occursin(r"UPPER_BOUNDS", line)
                current_section = "UPPER_BOUNDS"
            elseif occursin(r"ELIMINATION_ORDER", line)
                current_section = "ELIMINATION_ORDER"
            elseif occursin(r"INEQUALITIES_SECTION", line)
                current_section = "INEQUALITIES_SECTION" # equalities are with inequalities.
            elseif occursin(r"VALID", line)
                current_section = "VALID"
            end

            # if line contains a point
            if occursin(r"^(\(\s*\d+\))?(\s*[+-]?\s*[(\d+)x])+", line)
                if (current_section == "INEQUALITIES_SECTION")
                    # match terms like -x8 or +x11
                    lhs_matches = collect(eachmatch(r"([+-])\s*(?:(\d+)(?!\))(?:/(\d+))?)?x(\d+)", line))

                    # initializing empty vector
                    data_vector = zeros(Rational{Int64}, (1,dim + 1))
                    for lhs_match in lhs_matches
                        sign = lhs_match.captures[1]
                        num = (lhs_match.captures[2] === nothing) ? parse(Int64, sign*"1") : parse(Int64, sign*lhs_match.captures[2])
                        den = (lhs_match.captures[3] === nothing) ? 1 : parse(Int64, lhs_match.captures[3])
                        index = parse(Int64, lhs_match.captures[4])

                        data_vector[index] += Rational(num, den)
                    end

                    # match in/equality sign and rhs value
                    rhs_match = match(r"(<=|=<|>=|=>|==|=)\s*([-+]?)\s*(\d+)", line)

                    rel_sign = rhs_match.captures[1]
                    int_sign = (rhs_match.captures[2] === nothing) ? "+" : rhs_match.captures[2]
                    rhs_int = parse(Int64, int_sign*rhs_match.captures[3])
                    data_vector[end] = rhs_int

                    if (rel_sign == "<=") || (rel_sign == "=<")
                        push!(inequalities, data_vector)
                    elseif (rel_sign == ">=") || (rel_sign == "=>")
                        # if the lhs ≥ rhs then invert ≧ by multiplying by (-1).
                        push!(inequalities, -1 .* data_vector)
                    elseif (rel_sign == "=") || (rel_sign == "==")
                        push!(equalities, data_vector)
                    end
                else
                    digit_matches = collect(eachmatch(r"\s*([+-])?\s*(\d+)(?!\))(?:/(\d+))?", line))
                    num_matches = length(digit_matches)

                    # map makes col vectors reshape to be row vectors
                    point = reshape( map(regex -> begin
                        sign = (regex.captures[1] === nothing) ? "+" : regex.captures[1]
                        num = parse(Int64, sign*regex.captures[2])
                        den = (regex.captures[3] === nothing) ? 1 : parse(Int64, regex.captures[3])

                        Rational(num, den)
                    end, digit_matches), (1,num_matches))

                    if current_section == "LOWER_BOUNDS"
                        push!(lower_bounds, point)
                    elseif current_section == "UPPER_BOUNDS"
                        push!(upper_bounds, point)
                    elseif current_section == "ELIMINATION_ORDER"
                        push!(elimination_order, point)
                    elseif current_section == "VALID"
                        push!(valid, point)
                    end
                end
            end

            if occursin(r"END", line)
                break
            end
        end

        # for initializing empty IEQ fields
        null_matrix = Array{Rational{Int64}}(undef, 0, 0)

        IEQ(
            inequalities = (length(inequalities) == 0) ? null_matrix : vcat(inequalities...),
            equalities = (length(equalities) == 0) ? null_matrix : vcat(equalities...),
            upper_bounds = (length(upper_bounds) == 0) ? null_matrix : vcat(upper_bounds...),
            lower_bounds = (length(lower_bounds) == 0) ? null_matrix : vcat(lower_bounds...),
            elimination_order = (length(elimination_order) == 0) ? null_matrix : vcat(elimination_order...),
            valid = (length(valid) == 0) ? null_matrix : vcat(valid...)
        )
    end
end
#
#
# function write_poi(filename :: String, poi::POI{T,S}; dir::String="./") :: String
#     # TODO:
# end
#
# function write_ieq(filename :: String, ieq::IEQ{T,S,R,Q,P}; dir::String="./") :: String
#     # TODO:
# end
