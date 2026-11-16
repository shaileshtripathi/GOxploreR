test_that("getGOcategory returns the ontology of GO terms", {
    res <- getGOcategory(c("GO:0008150", "GO:0003674", "GO:0005575"))
    expect_s3_class(res, "data.frame")
    expect_equal(nrow(res), 3L)
})

test_that("BP level lookups are consistent", {
    terms <- Level2GOTermBP(level = 2, organism = "Human")
    expect_type(terms, "character")
    expect_true(length(terms) > 0)
    lv <- GOTermBPOnLevel(goterm = terms[1])
    expect_equal(as.numeric(lv$Level), 2)
})

test_that("invalid domain arguments are rejected", {
    expect_error(GetDAG(organism = "Human", domain = "XX"))
    expect_error(GetDAG(organism = 1))
})

test_that("GetDAG returns a two-column edgelist", {
    el <- GetDAG(organism = "Human", domain = "MF")
    expect_true(is.matrix(el))
    expect_equal(ncol(el), 2L)
})
