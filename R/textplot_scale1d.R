#' Plot a fitted scaling model
#' 
#' Plot the results of a fitted scaling model, from (e.g.) a predicted 
#' \link{textmodel_wordscores} model or a fitted \link{textmodel_wordfish} 
#' or \link{textmodel_ca}
#' model. Either document or feature parameters may be plotted: an ideal
#' point-style plot (estimated document position plus confidence interval on the
#' x-axis, document labels on the y-axis) with optional renaming and sorting, or
#' as a plot of estimated feature-level parameters (estimated feature positions
#' on the x-axis, and a measure of relative frequency or influence on the
#' y-axis, with feature names replacing plotting points with some being chosen
#' by the user to be highlighted).
#' @param x the fitted or predicted scaling model object to be plotted
#' @param margin \code{"documents"} to plot estimated document scores (the
#'   default) or \code{"features"} to plot estimated feature scores by a measure
#'   of relative frequency
#' @param sort if \code{TRUE} (the default), order points from low to high 
#'   score. If a vector, order according to these values from low to high. Only 
#'   applies when \code{margin = "documents"}.
#' @inheritParams groups 
#' @param doclabels a vector of names for document; if left NULL (the default), 
#'   docnames will be used
#' @param highlighted a vector of feature names to draw attention to in a 
#'   feature plot; only applies if \code{margin = "features"}
#' @param highlighted_color color for highlighted terms in \code{highlighted}
#' @param alpha A number between 0 and 1 (default 0.5) representing the level of
#'   alpha transparency used to overplot feature names in a feature plot; only 
#'   applies if \code{margin = "features"}
#' @return a \pkg{ggplot2} object
#' @note The \code{groups} argument only applies when \code{margin = "documents"}.
#' @export
#' @author Kenneth Benoit, Stefan Müller, and Adam Obeng
#' @seealso \code{\link{textmodel_wordfish}}, \code{\link{textmodel_wordscores}}, 
#'   \code{\link{textmodel_ca}}
#' @keywords textplot
#' @examples
#' \dontrun{
#' ie_dfm <- dfm(data_corpus_irishbudget2010)
#' doclab <- apply(docvars(data_corpus_irishbudget2010, c("name", "party")), 
#'                 1, paste, collapse = " ")
#' 
#' ## wordscores
#' refscores <- c(rep(NA, 4), 1, -1, rep(NA, 8))
#' ws <- textmodel_wordscores(ie_dfm, refscores, smooth = 1)
#' # plot estimated word positions
#' textplot_scale1d(ws, highlighted = c("minister", "have", "our", "budget"))
#' # plot estimated document positions
#' textplot_scale1d(predict(ws), doclabels = doclab,
#'                  groups = docvars(data_corpus_irishbudget2010, "party"))
#'
#' ## wordfish
#' wf <- textmodel_wordfish(dfm(data_corpus_irishbudget2010), dir = c(6,5))
#' # plot estimated document positions
#' textplot_scale1d(wf, doclabels = doclab)
#' textplot_scale1d(wf, doclabels = doclab,
#'                  groups = docvars(data_corpus_irishbudget2010, "party"))
#' # plot estimated word positions
#' textplot_scale1d(wf, margin = "features", 
#'                  highlighted = c("government", "global", "children", 
#'                                  "bank", "economy", "the", "citizenship",
#'                                  "productivity", "deficit"))
#'
#' ## correspondence analysis
#' ca <- textmodel_ca(ie_dfm)
#' # plot estimated document positions
#' textplot_scale1d(ca, margin = "documents",
#'                  doclabels = doclab,
#'                  groups = docvars(data_corpus_irishbudget2010, "party"))
#' }
textplot_scale1d <- function(x, 
                             margin = c("documents", "features"), 
                             doclabels = NULL, 
                             sort = TRUE, groups = NULL, 
                             highlighted = NULL, alpha = 0.7, 
                             highlighted_color = "black") {
    UseMethod("textplot_scale1d")
}

#' @export
textplot_scale1d.default <-  function(x,
                                      margin = c("documents", "features"), 
                                      doclabels = NULL, 
                                      sort = TRUE, groups = NULL, 
                                      highlighted = NULL, alpha = 0.7, 
                                      highlighted_color = "black") {
    stop(friendly_class_undefined_message(class(x), "textplot_scale1d"))
}

#' @importFrom stats reorder aggregate
#' @importFrom ggplot2 ggplot aes geom_point element_blank geom_pointrange 
#' @importFrom ggplot2 coord_flip xlab ylab theme_bw geom_text theme geom_point
#' @importFrom ggplot2 facet_grid element_line
#' @export
textplot_scale1d.textmodel_wordfish <-  function(x, 
                                                 margin = c("documents", "features"), 
                                                 doclabels = NULL, 
                                                 sort = TRUE, 
                                                 groups = NULL, 
                                                 highlighted = NULL, 
                                                 alpha = 0.7, 
                                                 highlighted_color = "black") {
    margin <- match.arg(margin)
    if (is.null(doclabels)) doclabels <- x$docs
    
    if (margin == "documents") {
        p <- textplot_scale1d_documents(x$theta,
                                        x$se.theta, 
                                        doclabels = doclabels, 
                                        sort = sort, 
                                        groups = groups) +
            ylab("Estimated theta")
    } else if (margin == "features") {
        p <- textplot_scale1d_features(x$beta, 
                                       weight = x$psi, 
                                       featlabels = x$features,
                                       highlighted = highlighted, alpha = alpha,
                                       highlighted_color = highlighted_color) +
            xlab("Estimated beta") +
            ylab("Estimated psi")
    } 
    apply_theme(p)
} 
     
#' @importFrom stats reorder aggregate
#' @importFrom ggplot2 ggplot aes geom_point element_blank geom_pointrange 
#' @importFrom ggplot2 coord_flip xlab ylab theme_bw geom_text theme geom_point
#' @importFrom ggplot2 facet_grid element_line
#' @method textplot_scale1d predict.textmodel_wordscores
#' @export
textplot_scale1d.predict.textmodel_wordscores <- function(x, 
                                                          margin = c("documents", "features"), 
                                                          doclabels = NULL, 
                                                          sort = TRUE, 
                                                          groups = NULL, 
                                                          highlighted = NULL, 
                                                          alpha = 0.7, 
                                                          highlighted_color = "black") {
    margin <- match.arg(margin)
    if (is.null(doclabels)) doclabels <- get_docnames(x)
    
    if (margin == "documents") {
        p <- textplot_scale1d_documents(get_fitted(x), 
                                        get_sefit(x), 
                                        doclabels = doclabels, 
                                        sort = sort, 
                                        groups = groups) +
              ylab("Document position")
        
    } else if (margin == "features") {
        stop("This margin can only be run on a fitted wordscores object.")
    } 
    apply_theme(p)
}


#' @export
textplot_scale1d.textmodel_wordscores <- function(x, 
                                                  margin = c("features", "documents"), 
                                                  doclabels = NULL, 
                                                  sort = TRUE, 
                                                  groups = NULL, 
                                                  highlighted = NULL, 
                                                  alpha = 0.7, 
                                                  highlighted_color = "black") {
    margin <- match.arg(margin)
    if (margin == "documents") {
        stop("This margin can only be run on a predicted wordscores object.")
    } else if (margin == "features") {
        p <- textplot_scale1d_features(x$wordscores, 
                                       weight = log(colSums(x$x[, names(x$wordscores)])),
                                       featlabels = names(x$wordscores),
                                       highlighted = highlighted, alpha = alpha,
                                       highlighted_color = highlighted_color) +
            xlab("Word score") +
            ylab("log(term frequency)") 
        apply_theme(p)
    }
}

#' @importFrom stats reorder aggregate
#' @importFrom ggplot2 ggplot aes geom_point element_blank geom_pointrange 
#' @importFrom ggplot2 coord_flip xlab ylab theme_bw geom_text theme geom_point
#' @importFrom ggplot2 facet_grid element_line
#' @export
textplot_scale1d.textmodel_ca <- function(x, 
                                          margin = c("documents", "features"), 
                                          doclabels = NULL, 
                                          sort = TRUE, 
                                          groups = NULL, 
                                          highlighted = NULL, 
                                          alpha = 0.7, 
                                          highlighted_color = "black") {
    margin <- match.arg(margin)
    if (is.null(doclabels)) doclabels <- x$rownames
    
    if (margin == "documents") {
        p <- textplot_scale1d_documents(coef(x)$coef_document, 
                                        coef(x)$coef_document_se, 
                                        doclabels = doclabels, 
                                        sort = sort, 
                                        groups = groups) +
            ylab("Document position")
        
    } else {
        stop("textplot_scale1d for features not implemented for CA models")
    }
    apply_theme(p)
}


# internal fns --------

textplot_scale1d_documents <- function(x, se, doclabels, sort = TRUE, 
                                       groups = NULL) {

    if (!is.null(doclabels))
        stopifnot(length(doclabels) == length(x))
    
    if (all(is.na(se))) se <- 0
    
    if (sort & !is.null(groups)) {
        temp_medians <- aggregate(x, list(groups), median, na.rm = TRUE)
        groups <- factor(groups, 
                         levels = temp_medians[order(temp_medians$x, decreasing = TRUE), 1])
    }
    
    theta <- lower <- upper <- NULL
    results <- data.frame(doclabels = doclabels, 
                          theta = x, 
                          lower = x - 1.96 * se, 
                          upper = x + 1.96 * se)
    if (!is.null(groups))
        results$groups <- groups
    
    p <- if (sort) {
        ggplot(data = results, aes(x = reorder(doclabels, theta), y = theta))
    } else {
        ggplot(data = results, aes(x = doclabels, y = theta))
    }
    
    p <- p + 
        coord_flip() + 
        geom_point(size = 1) +
        geom_pointrange(aes(ymin = lower, ymax = upper), 
                        lwd = .25, fatten = .4) +
        xlab(NULL)
    if (!is.null(groups)) {
        p <- p + facet_grid(as.factor(groups) ~ ., scales = "free_y", space = "free")
    }  
    p
}

##
## internal function to plot document scaling
##
textplot_scale1d_features <- function(x, weight, featlabels,
                                      highlighted = NULL, alpha = 0.7, 
                                      highlighted_color = "black") {
        
    beta <- psi <- feature <- NULL
    results <- data.frame(feature = featlabels, 
                          psi = weight,
                          beta = x)
    p <- ggplot(data = results, aes(x = beta, y = psi, label = feature)) + 
        geom_text(colour = "grey70") +
        geom_text(aes(beta, psi, label = feature), 
                  data = results[results$feature %in% highlighted,],
                  color = highlighted_color) +
        xlab("Beta") +
        ylab("Psi") + 
        theme(panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank())
    p
}

##
## common minimal B&W theme
##
apply_theme <- function(p) {
    p + theme_bw() + 
        theme(panel.background = ggplot2::element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.x = element_blank(), 
              # panel.grid.major.y = element_blank(),
              panel.grid.minor.y = element_blank(), 
              plot.background = element_blank(),
              axis.ticks.y = element_blank(), 
              # panel.spacing = grid::unit(0.1, "lines"),
              panel.grid.major.y = element_line(linetype = "dotted"))
}


# internal functions --------

get_docnames <- function(x) {
    if (is.null(dim(x))) {
        dnames <- names(x)
    } else {
        if (is.list(x)) 
            dnames <- row.names(x$fit)
        else
            dnames <- row.names(x)
    }
    dnames
}

get_fitted <- function(x) {
    if (is.list(x)) x <- x$fit
    if (is.numeric(x)) {
        fit <- x
    } else {
        fit <- x[, "fit"]
    }
    fit
}

get_sefit <- function(x) {
    # se is zero if prediction is estimates
    if (is.numeric(x)) return(rep(0, length(x)))
    if (is.list(x) && !is.null(x$se.fit)) {
        return(x$se.fit)
    } else {
        return((x[, "fit"] - x[, "lwr"]) / 1.96)  
    }
}
