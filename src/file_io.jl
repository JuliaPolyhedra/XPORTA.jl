"""
    read_poi(filepath :: String) :: POI{ Rational{Int64}, Rational{Int64} }

Creates a `POI` struct by parsing the provided `.poi` file. A `DomainError` is thrown
if argument `filepath` does not end with the `.poi` extension.
"""
function read_poi(filepath :: String)::POI{ Rational{Int64}, Rational{Int64} }
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
            if occursin(r"^(\(\s*\d+\))?(\s*\d+)+", line)
                digit_matches = collect(eachmatch(r"\s*(\d+)(?!\))(?:/(\d+))?", line))
                num_matches = length(digit_matches)

                # map makes col vectors reshape to be row vectors
                point = reshape( map(regex -> begin
                    num = parse(Int64, regex.captures[1])
                    den = (regex.captures[2] === nothing) ? 1 : parse(Int64, regex.captures[2])

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

# function read_ieq(filepath::String)::POI{Rational{Int64},Rational{Int64}}
#   # TODO:
# end
#
#
# function write_poi(filename :: String, poi::POI{T,S}; dir::String="./") :: String
#     # TODO:
# end
#
# function write_ieq(filename :: String, ieq::IEQ{T,S,R,Q,P}; dir::String="./") :: String
#     # TODO:
# end
