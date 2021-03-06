#' Title
#'
#' @param object 
#' @param value 
#' @param algorithm 
#' @param case 
#' @param by 
#' @param annotator 
#' @param smallBetter 
#' @param na.treat 
#' @param check 
#'
#' @return
#' @export
#'
#' @examples
as.challenge=function(object, 
                      value, 
                      algorithm ,
                      case=NULL,
                      by=NULL, 
                      annotator=NULL, 
                      smallBetter=FALSE,
                      na.treat=NULL, # optional
                      check=TRUE){

  object=object[,c(value,algorithm,case,by,annotator)]
 
  # if (missing(na.treat)){
  #   if (!smallBetter){
  #     message("Setting na.treat=0, i.e. setting any missing metric value to zero.")
  #     na.treat=0
  # }
  
  # sanity checks
  if (check){
      if (is.null(by)){
        missingData=object %>% 
          expand(!!as.symbol(algorithm),
                 !!as.symbol(case)) %>% 
          anti_join(object,
                    by=c(algorithm,case))
        if (nrow(missingData)>0) {
          message("Performance of not all algorithms is observed for all cases. Inserted as missings in following cases:")
          print(as.data.frame(missingData))
          object=as.data.frame(object %>% 
                                 complete(!!as.symbol(algorithm),
                                          !!as.symbol(case)))
      } else {
        object=droplevels(object)
        all1=apply(table(object[[algorithm]],
                         object[[case]]), 
                   2,
                   function(x) all(x==1))
        if (!all(all1)) stop ("Case(s) (", 
                              paste(names(which(all1!=1)),
                                    collapse=", "), 
                              ") appear(s) more than once for the same algorithm")
        
      }
        
      if (!is.null(na.treat)){
        if (is.numeric(na.treat)) object[,value][is.na(object[,value])]=na.treat
        else if (is.function(na.treat)) object[,value][is.na(object[,value])]=na.treat(object[,value][is.na(object[,value])])
        else if (na.treat=="na.rm") object=object[!is.na(object[,value]),]
      }
        
    } else {
        object=splitby(object,by=by)
        object=lapply(object,droplevels)
        for (task in names(object)){
          missingData=object[[task]] %>% 
            expand(!!as.symbol(algorithm),
                   !!as.symbol(case))%>% 
            anti_join(object[[task]],
                      by=c( algorithm,case))
          if (nrow(missingData)>0) {
            message("Performance of not all algorithms is observed for all cases in task ",
                    task,
                    ". Inserted as missings in following cases:")
            print(as.data.frame(missingData))
            object[[task]]=as.data.frame(object[[task]] %>% 
                                           complete(!!as.symbol(algorithm),
                                                    !!as.symbol(case)))
           } else {
            all1=apply(table(object[[task]][[algorithm]],
                             object[[task]][[case]]), 
                       2,
                       function(x) all(x==1))
            if (!all(all1)) stop ("Case(s) (", 
                                  paste(names(which(all1!=1)),
                                        collapse=", "), 
                                  ") appear(s) more than once for the same algorithm in task ", 
                                  task)
           }
        
          if (!is.null(na.treat)){
            if (is.numeric(na.treat)) object[[task]][,value][is.na(object[[task]][,value])]=na.treat
            else if (is.function(na.treat)) object[[task]][,value][is.na(object[[task]][,value])]=na.treat(object[[task]][,value][is.na(object[[task]][,value])])
            else if (na.treat=="na.rm") object[[task]]=object[[task]][!is.na(object[[task]][,value]),]
          }
          
        }
  
    }
    
  }
  
  attr(object,"algorithm")=algorithm
  attr(object,"value")=value
  attr(object,"case")=case
  attr(object,"annotator")=annotator
  attr(object,"by")=by 
  attr(object,"largeBetter")=!smallBetter
  attr(object,"check")=check
  class(object)=c("challenge",class(object))
  object
}


