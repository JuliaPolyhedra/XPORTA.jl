"""
    read_poi( filepath::String ) :: POI{Rational{Int}}

Constructs a `POI` struct by parsing the provided `.poi` file. A `DomainError` is thrown
if argument `filepath` does not end with the `.poi` extension.
"""
function read_poi(filepath :: String)::POI{Rational{Int}}
    if !(occursin(r"\.poi$", filepath))
        throw(DomainError(filepath, "filepath does not end in extension `.poi`."))
    end

    open(filepath) do file
        lines = readlines(file)

        # initializing mutable variables
        current_section = ""
        dim = 0

        # vertices, rays, and valid points will be accumulated then concatenated
        conv_section_rows = Array{Array{Rational{Int},2},1}(undef, 0)
        cone_section_rows = Array{Array{Rational{Int},2},1}(undef, 0)
        valid_rows = Array{Array{Rational{Int},2},1}(undef, 0)

        # reading file line by line
        for line in lines
            # .poi files are headed with DIM = <num_dimensions>
            dim_match = match(r"^DIM = (\d+)$",line)
            if dim_match != nothing
                dim = parse(Int,dim_match.captures[1])
            end

            if occursin(r"CONV_SECTION", line)
                current_section = "CONV_SECTION"
            elseif occursin(r"CONE_SECTION", line)
                current_section = "CONE_SECTION"
            elseif occursin(r"VALID", line)
                current_section = "VALID"
            end

            # if line contains a vertex/ray
            if occursin(r"^(\(\s*\d+\))?(\s*([+-])?\s*\d+)+", line)
                digit_matches = collect(eachmatch(r"(?:\(\s*\d+\))?\s*([+-])?\s*(\d+)(?:\/(\d+))?", line))
                num_matches = length(digit_matches)

                # map makes col vectors reshape to be row vectors
                point = reshape( map(regex -> begin
                    sign = (regex.captures[1] === nothing) ? "+" : regex.captures[1]
                    num = parse(Int, sign*regex.captures[2])
                    den = (regex.captures[3] === nothing) ? 1 : parse(Int, regex.captures[3])

                    Rational(num, den)
                end, digit_matches), (1,num_matches))

                if current_section == "CONV_SECTION"
                    push!(conv_section_rows, point)
                elseif current_section == "CONE_SECTION"
                    push!(cone_section_rows, point)
                elseif current_section == "VALID"
                    push!(valid_rows, point)
                end
            end

            if occursin(r"END", line)
                break
            end
        end

        null_matrix = Array{Rational{Int}}(undef, 0, 0)
        vertices = (length(conv_section_rows) == 0) ? null_matrix : vcat(conv_section_rows...)
        rays = (length(cone_section_rows) == 0) ? null_matrix : vcat(cone_section_rows...)
        valid = (length(valid_rows) == 0) ? null_matrix : vcat(valid_rows...)

        POI(vertices=vertices, rays=rays, valid=valid)
    end
end

"""
    read_ieq( filepath::String ) :: IEQ{Rational{Int}}

Constructs an `IEQ` struct by parsing the provided `.ieq` file. A `DomainError` is thrown
if argument `filepath` does not end with the `.ieq` extension.
"""
function read_ieq(filepath::String)::IEQ{Rational{Int}}
    if !(occursin(r"\.ieq$", filepath))
        throw(DomainError(filepath, "filepath does not end in extension `.ieq`."))
    end

    open(filepath) do file
        lines = readlines(file)

        # initializing mutable variables
        current_section = ""
        dim = 0

        # in/equalites, bounds, etc. rows will be accumulated and concatenated
        inequality_rows = Array{Array{Rational{Int},2},1}(undef, 0)
        equality_rows  = Array{Array{Rational{Int},2},1}(undef, 0)
        upper_bounds_row = Array{Array{Int,2},1}(undef, 0)
        lower_bounds_row = Array{Array{Int,2},1}(undef, 0)
        elimination_order_row = Array{Array{Int,2},1}(undef, 0)
        valid_row = Array{Array{Rational{Int},2},1}(undef, 0)

        for line in lines
            # .ieq files are headed with DIM = <num_dimensions>
            dim_match = match(r"^DIM = (\d+)$",line)
            if dim_match != nothing
                dim = parse(Int,dim_match.captures[1])
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
                    lhs_matches = collect(eachmatch(r"(?:\(\s*\d+\))?\s*([+-])\s*(?:(\d+)(?!\))(?:/(\d+))?)?x(\d+)", line))

                    # initializing empty vector
                    data_vector = zeros(Rational{Int}, (1,dim + 1))
                    for lhs_match in lhs_matches
                        sign = lhs_match.captures[1]
                        num = (lhs_match.captures[2] === nothing) ? parse(Int, sign*"1") : parse(Int, sign*lhs_match.captures[2])
                        den = (lhs_match.captures[3] === nothing) ? 1 : parse(Int, lhs_match.captures[3])
                        index = parse(Int, lhs_match.captures[4])

                        data_vector[index] += Rational(num, den)
                    end

                    # match in/equality sign and rhs value
                    rhs_match = match(r"(<=|=<|>=|=>|==|=)\s*([-+]?)\s*(\d+)", line)

                    rel_sign = rhs_match.captures[1]
                    int_sign = (rhs_match.captures[2] === nothing) ? "+" : rhs_match.captures[2]
                    rhs_int = parse(Int, int_sign*rhs_match.captures[3])
                    data_vector[end] = rhs_int

                    if (rel_sign == "<=") || (rel_sign == "=<")
                        push!(inequality_rows, data_vector)
                    elseif (rel_sign == ">=") || (rel_sign == "=>")
                        # if the lhs ≥ rhs then invert ≧ by multiplying by (-1).
                        push!(inequality_rows, -1 .* data_vector)
                    elseif (rel_sign == "=") || (rel_sign == "==")
                        push!(equality_rows, data_vector)
                    end
                elseif current_section ==  "VALID"
                    digit_matches = collect(eachmatch(r"\s*([+-])?\s*(\d+)(?:/(\d+))?", line))
                    num_matches = length(digit_matches)

                    # map makes col vectors reshape to be row vectors
                    point = reshape( map(regex -> begin
                        sign = (regex.captures[1] === nothing) ? "+" : regex.captures[1]
                        num = parse(Int, sign*regex.captures[2])
                        den = (regex.captures[3] === nothing) ? 1 : parse(Int, regex.captures[3])

                        return Rational(num, den)
                    end, digit_matches), (1,num_matches))

                    push!(valid_row, point)
                else
                    digit_matches = collect(eachmatch(r"\s*([+-])?\s*(\d+)(?!\))", line))
                    num_matches = length(digit_matches)

                    # map makes col vectors reshape to be row vectors
                    point = reshape( map(regex -> begin
                        sign = (regex.captures[1] === nothing) ? "+" : regex.captures[1]
                        num = parse(Int, sign*regex.captures[2])

                        return num
                    end, digit_matches), (1,num_matches))

                    if current_section == "LOWER_BOUNDS"
                        push!(lower_bounds_row, point)
                    elseif current_section == "UPPER_BOUNDS"
                        push!(upper_bounds_row, point)
                    elseif current_section == "ELIMINATION_ORDER"
                        push!(elimination_order_row, point)
                    end
                end
            end

            if occursin(r"END", line)
                break
            end
        end

        # for initializing empty IEQ fields
        null_matrix = Array{Int}(undef, 0, 0)

        IEQ(
            inequalities = (length(inequality_rows) == 0) ? null_matrix : vcat(inequality_rows...),
            equalities = (length(equality_rows) == 0) ? null_matrix : vcat(equality_rows...),
            upper_bounds = (length(upper_bounds_row) == 0) ? null_matrix : vcat(upper_bounds_row...),
            lower_bounds = (length(lower_bounds_row) == 0) ? null_matrix : vcat(lower_bounds_row...),
            elimination_order = (length(elimination_order_row) == 0) ? null_matrix : vcat(elimination_order_row...),
            valid = (length(valid_row) == 0) ? null_matrix : vcat(valid_row...)
        )
    end
end

"""
    write_poi(filename::String, poi::POI; dir::String="./") :: String

Writes a `.poi` file, `dir/filename.poi`, from the provided `POI`. If `filename`
does not explicitly have the `.poi` extension, it will automatically be added. The
method returns the complete file path for the created file, `dir/filename.poi`.
"""
function write_poi(filename::String, poi::POI; dir::String="./") :: String
    sep = occursin(r"/$", dir) ? "" : "/"
    ext = occursin(r"\.poi$", filename) ? "" : ".poi"
    filepath = dir * sep * filename * ext

    open(filepath, "w") do file
        # adding DIM line
        println(file, "DIM = ", poi.dim, "\n")

        poi_sections =  [
            ("VALID", poi.valid),
            ("CONV_SECTION", poi.conv_section),
            ("CONE_SECTION", poi.cone_section)
        ]

        for section in poi_sections
            # only write a section if there are points
            if length(section[2]) > 0
                println(file, "\n", section[1])

                for row_id in 1:size(section[2])[1]
                    println(file, " ", replace(join(section[2][row_id,:], " "), r"//" => s"/"))
                end
            end
        end

        println(file, "\nEND\n")
    end

    return filepath
end

"""
    write_ieq( filename::String, ieq::IEQ; dir::String="./") :: String

Writes an `.ieq` file, `dir/filename.ieq`, from the provided `IEQ` struct. If
`filename` does not explicitly contain the `.ieq` extension, it will be added
automatically. The method returns the complete file path for the created file,
`dir/filename.ieq`.
"""
function write_ieq(filename::String, ieq::IEQ; dir::String="./") :: String
    sep = occursin(r"/$", dir) ? "" : "/"
    ext = occursin(r"\.ieq$", filename) ? "" : ".ieq"
    filepath = dir * sep * filename * ext

    open(filepath, "w") do file
        # adding DIM line
        println(file, "DIM = ", ieq.dim, "\n")

        ieq_sections =  [
            ("VALID", ieq.valid),
            ("LOWER_BOUNDS", ieq.lower_bounds),
            ("UPPER_BOUNDS", ieq.upper_bounds),
            ("ELIMINATION_ORDER", ieq.elimination_order)
        ]

        for section in ieq_sections
            # only write a section if there are points
            if length(section[2]) > 0
                println(file, "\n", section[1])

                for row_id in 1:size(section[2])[1]
                    println(file, " ", replace(join(section[2][row_id,:], " "), r"//" => s"/"))
                end
            end
        end

        if (length(ieq.equalities) > 0) || (length(ieq.inequalities) > 0)
            # equalities and inequalities are found in the INEQUALITIES_SECTION
            println(file, "\nINEQUALITIES_SECTION")

            # writing equalities
            if (length(ieq.equalities) > 0)
                for row_id in 1:size(ieq.equalities)[1]
                    for col_id in 1:length(ieq.equalities[row_id,1:end-1])
                        el = ieq.equalities[row_id, col_id]
                        if el == 0
                            continue
                        end

                        el_sign = (el > 0) ? "+" : ""
                        el_str = replace(string(el), r"//" => s"/")
                        id_str = string(col_id)

                        print(file, " ", el_sign, el_str, "x", id_str,)
                    end

                    print(file, " == ")
                    println(file, replace(string(ieq.equalities[row_id,end]), r"//" => s"/"))
                end

                println(file, "\n")
            end

            # writing inequalities
            if (length(ieq.inequalities) > 0)
                for row_id in 1:size(ieq.inequalities)[1]
                    for col_id in 1:length(ieq.inequalities[row_id, 1:end-1])
                        el = ieq.inequalities[row_id, col_id]
                        if el == 0
                            continue
                        end

                        el_sign = (el > 0) ? "+" : ""
                        el_str = replace(string(el), r"//" => s"/")
                        id_str = string(col_id)

                        print(file, " ", el_sign, el_str, "x", id_str,)
                    end

                    print(file, " <= ")
                    println(file, replace(string(ieq.inequalities[row_id,end]), r"//" => s"/"))
                end
            end
        end

        println(file, "\nEND\n")
    end

    return filepath
end
