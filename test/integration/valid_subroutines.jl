using Test, XPORTA

@testset "src/valid_subroutines.jl" begin

dir = "./test/files/"

@testset "run_valid()" begin
    @testset "throws DomainError if method_flag is not recognized" begin
        @test_throws DomainError XPORTA.run_xporta("-X", ["dir/example1.poi"])
    end    
end

end
