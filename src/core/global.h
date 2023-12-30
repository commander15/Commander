#ifndef COMMANDER_GLOBAL_H
#define COMMANDER_GLOBAL_H

#include <Commander/config.h>

#ifdef COMMANDER_SHARED
#ifdef COMMANDER_BUILD
#define COMMANDER_EXPORT Q_DECL_EXPORT
#else
#define COMMANDER_EXPORT Q_DECL_IMPORT
#endif
#else
#define COMMANDER_EXPORT
#endif

#define COMMANDER_D(ClassName) \
    ClassName##Private *d = static_cast<ClassName##Private *>(qGetPtrHelper(this->d))

#endif // COMMANDER_GLOBAL_H
