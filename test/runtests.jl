using Test, UUIDs

using AnalyzeRegistry

@testset "AnalyzeRegistry" begin
    general = general_registry()
    @test isdir(general)
    @test all(isdir, find_packages())
    # Test some properties of the `Measurements` package.  NOTE: they may change
    # in the future!
    measurements = analyze_from_registry(joinpath(general, "M", "Measurements"))
    @test measurements.uuid == UUID("eff96d63-e80a-5855-80a2-b1b0885c5ab7")
    @test measurements.reachable
    @test measurements.docs
    @test measurements.runtests
    @test !measurements.buildkite
    # Test results of a couple of packages.  Same caveat as above
    packages = [joinpath(general, p...) for p in (("C", "Cuba"), ("P", "PolynomialRoots"))]
    results = analyze_from_registry(packages)
    cuba, polyroots = results
    @test length(filter(p -> p.reachable, results)) == 2
    @test length(filter(p -> p.runtests, results)) == 2
    @test cuba.drone
    @test !polyroots.docs # Documentation is in the README!
    # We can also use broadcasting!
    @test Set(results) == Set(analyze_from_registry.(packages))

    # check `analyze_from_registry!` directly
    mktempdir() do root
        measurements2 = analyze_from_registry!(root, joinpath(general, "M", "Measurements"))
        @test measurements == measurements2
        @test isdir(joinpath(root, "eff96d63-e80a-5855-80a2-b1b0885c5ab7")) # not cleaned up yet
    end
end

@testset "`analyze`" begin
    pkg = analyze(pkgdir(AnalyzeRegistry))
    @test pkg.repo == "" # can't find repo from source code
    @test pkg.uuid == UUID("e713c705-17e4-4cec-abe0-95bf5bf3e10c")
    @test pkg.reachable == true # default
    @test pkg.docs == false
    @test pkg.runtests == true # here we are!
    @test pkg.github_actions == true
end