#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MaterialBottomSheet.h"
#import "MDCBottomSheetController.h"
#import "MDCBottomSheetPresentationController.h"
#import "MDCBottomSheetTransitionController.h"
#import "MDCSheetState.h"
#import "UIViewController+MaterialBottomSheet.h"
#import "MaterialShadowElevations.h"
#import "MDCShadowElevations.h"
#import "MaterialShadowLayer.h"
#import "MDCShadowLayer.h"
#import "MaterialShapeLibraryNew.h"
#import "MDCCornerTreatment+CornerTypeInitalizerNew.h"
#import "MDCCurvedCornerTreatmentNew.h"
#import "MDCCurvedRectShapeGeneratorNew.h"
#import "MDCCutCornerTreatmentNew.h"
#import "MDCPillShapeGeneratorNew.h"
#import "MDCRoundedCornerTreatmentNew.h"
#import "MDCSlantedRectShapeGeneratorNew.h"
#import "MDCTriangleEdgeTreatmentNew.h"
#import "MaterialShapesNew.h"
#import "MDCCornerTreatmentNew.h"
#import "MDCEdgeTreatmentNew.h"
#import "MDCPathGeneratorNew.h"
#import "MDCRectangleShapeGeneratorNew.h"
#import "MDCShapedShadowLayerNew.h"
#import "MDCShapedViewNew.h"
#import "MDCShapeGeneratingNew.h"
#import "MaterialApplication.h"
#import "UIApplication+AppExtensions.h"
#import "MaterialKeyboardWatcher.h"
#import "MDCKeyboardWatcher.h"
#import "MaterialMath.h"
#import "MDCMath.h"

FOUNDATION_EXPORT double MaterialComponentsVersionNumber;
FOUNDATION_EXPORT const unsigned char MaterialComponentsVersionString[];

