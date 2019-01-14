# This Makefile is for the prep_api extension to perl.
#
# It was generated automatically by MakeMaker version
# 7.1001 (Revision: 71001) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#

#   MakeMaker Parameters:

#     ABSTRACT => q[PREP API]
#     AUTHOR => [q[Lucas Ansei <lucastakushi@hotmail.com.com>]]
#     BUILD_REQUIRES => {  }
#     CONFIGURE_REQUIRES => { ExtUtils::MakeMaker=>q[0] }
#     DISTNAME => q[prep_api]
#     EXE_FILES => [q[bin/schema.dump.sh]]
#     LICENSE => q[open_source]
#     MIN_PERL_VERSION => q[5.014002]
#     NAME => q[prep_api]
#     PREREQ_PM => { App::Sqitch=>q[0.9996], Config::General=>q[0], Crypt::PRNG=>q[0], DBD::Pg=>q[0], DBIx::Class::Core=>q[0], DBIx::Class::InflateColumn::Serializer=>q[0], DBIx::Class::PassphraseColumn=>q[0], DBIx::Class::ResultSet=>q[0], DBIx::Class::Schema=>q[0], DBIx::Class::TimeStamp=>q[0], DDP=>q[0], Data::Diver=>q[0], Data::Manager=>q[0], Data::Printer=>q[0], Data::Section::Simple=>q[0], Data::Validate::URI=>q[0], Data::Verifier::Field=>q[0], Data::Verifier::Filters=>q[0], Data::Verifier::Results=>q[0], Data::Visitor=>q[0], Data::Visitor::Callback=>q[0], Exporter=>q[0], File::Spec=>q[0], FindBin=>q[0], IO::Handle=>q[0], IPC::Open3=>q[0], Mojo::Base=>q[0], Mojo::Util=>q[0], Moose=>q[0], Moose::Role=>q[0], Moose::Util::TypeConstraints=>q[0], MooseX::MarkAsMethods=>q[0], MooseX::NonMoose=>q[0], MooseX::Types=>q[0], Scalar::Util=>q[0], Test::Mojo=>q[0], Test::More=>q[0], common::sense=>q[0], lib=>q[0], namespace::autoclean=>q[0], strict=>q[0], utf8=>q[0], vars=>q[0], warnings=>q[0] }
#     TEST_REQUIRES => { File::Spec=>q[0], IO::Handle=>q[0], IPC::Open3=>q[0], Mojo::Util=>q[0], Test::Mojo=>q[0], Test::More=>q[0], lib=>q[0] }
#     VERSION => q[20190114]
#     test => { TESTS=>q[t/*.t t/chatbot/*.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0/x86_64-linux/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = cc
CCCDLFLAGS = -fPIC
CCDLFLAGS = -Wl,-E
DLEXT = so
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = cc
LDDLFLAGS = -shared -O2 -L/usr/local/lib -fstack-protector-strong
LDFLAGS =  -fstack-protector-strong -L/usr/local/lib
LIBC = libc-2.23.so
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 4.8.0-53-generic
RANLIB = :
SITELIBEXP = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/site_perl/5.24.0
SITEARCHEXP = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/site_perl/5.24.0/x86_64-linux
SO = so
VENDORARCHEXP = 
VENDORLIBEXP = 


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = prep_api
NAME_SYM = prep_api
VERSION = 20190114
VERSION_MACRO = VERSION
VERSION_SYM = 20190114
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 20190114
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3
INSTALLDIRS = site
DESTDIR = 
PREFIX = $(SITEPREFIX)
PERLPREFIX = /home/lucas/perl5/perlbrew/perls/perl-5.24.0
SITEPREFIX = /home/lucas/perl5/perlbrew/perls/perl-5.24.0
VENDORPREFIX = 
INSTALLPRIVLIB = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/site_perl/5.24.0
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = 
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0/x86_64-linux
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/site_perl/5.24.0/x86_64-linux
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = 
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = 
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = 
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = 
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = 
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0
PERL_ARCHLIB = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0/x86_64-linux
PERL_ARCHLIBDEP = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0/x86_64-linux
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0/x86_64-linux/CORE
PERL_INCDEP = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0/x86_64-linux/CORE
PERL = "/home/lucas/perl5/perlbrew/perls/perl-5.24.0/bin/perl"
FULLPERL = "/home/lucas/perl5/perlbrew/perls/perl-5.24.0/bin/perl"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /home/lucas/perl5/perlbrew/perls/perl-5.24.0/lib/5.24.0/ExtUtils/MakeMaker.pm
MM_VERSION  = 7.1001
MM_REVISION = 71001

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = prep_api
BASEEXT = prep_api
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = 
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = lib/Data/Verifier.pm \
	lib/Prep/Schema/Result/ChatbotSession.pm \
	lib/Prep/Schema/Result/Recipient.pm \
	lib/Prep/Schema/Result/Role.pm \
	lib/Prep/Schema/Result/User.pm \
	lib/Prep/Schema/Result/UserRole.pm \
	lib/Prep/Schema/Result/UserSession.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIBDEP)$(DFSEP)Config.pm $(PERL_INCDEP)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVEDEP    = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/Data/Verifier.pm \
	lib/Mojolicious/Plugin/Detach.pm \
	lib/Mojolicious/Plugin/SimpleAuthentication.pm \
	lib/Prep.pm \
	lib/Prep/Authentication.pm \
	lib/Prep/Authorization.pm \
	lib/Prep/Controller.pm \
	lib/Prep/Controller/Chatbot.pm \
	lib/Prep/Controller/Chatbot/Recipient.pm \
	lib/Prep/Data/Manager.pm \
	lib/Prep/Data/Visitor.pm \
	lib/Prep/Role/Verification.pm \
	lib/Prep/Role/Verification/TransactionalActions.pm \
	lib/Prep/Role/Verification/TransactionalActions/DBIC.pm \
	lib/Prep/Routes.pm \
	lib/Prep/Schema.pm \
	lib/Prep/Schema/Result/ChatbotSession.pm \
	lib/Prep/Schema/Result/Recipient.pm \
	lib/Prep/Schema/Result/Role.pm \
	lib/Prep/Schema/Result/User.pm \
	lib/Prep/Schema/Result/UserRole.pm \
	lib/Prep/Schema/Result/UserSession.pm \
	lib/Prep/Schema/Resultset/Recipient.pm \
	lib/Prep/SchemaConnected.pm \
	lib/Prep/Types.pm \
	lib/Prep/Utils.pm

PM_TO_BLIB = lib/Data/Verifier.pm \
	blib/lib/Data/Verifier.pm \
	lib/Mojolicious/Plugin/Detach.pm \
	blib/lib/Mojolicious/Plugin/Detach.pm \
	lib/Mojolicious/Plugin/SimpleAuthentication.pm \
	blib/lib/Mojolicious/Plugin/SimpleAuthentication.pm \
	lib/Prep.pm \
	blib/lib/Prep.pm \
	lib/Prep/Authentication.pm \
	blib/lib/Prep/Authentication.pm \
	lib/Prep/Authorization.pm \
	blib/lib/Prep/Authorization.pm \
	lib/Prep/Controller.pm \
	blib/lib/Prep/Controller.pm \
	lib/Prep/Controller/Chatbot.pm \
	blib/lib/Prep/Controller/Chatbot.pm \
	lib/Prep/Controller/Chatbot/Recipient.pm \
	blib/lib/Prep/Controller/Chatbot/Recipient.pm \
	lib/Prep/Data/Manager.pm \
	blib/lib/Prep/Data/Manager.pm \
	lib/Prep/Data/Visitor.pm \
	blib/lib/Prep/Data/Visitor.pm \
	lib/Prep/Role/Verification.pm \
	blib/lib/Prep/Role/Verification.pm \
	lib/Prep/Role/Verification/TransactionalActions.pm \
	blib/lib/Prep/Role/Verification/TransactionalActions.pm \
	lib/Prep/Role/Verification/TransactionalActions/DBIC.pm \
	blib/lib/Prep/Role/Verification/TransactionalActions/DBIC.pm \
	lib/Prep/Routes.pm \
	blib/lib/Prep/Routes.pm \
	lib/Prep/Schema.pm \
	blib/lib/Prep/Schema.pm \
	lib/Prep/Schema/Result/ChatbotSession.pm \
	blib/lib/Prep/Schema/Result/ChatbotSession.pm \
	lib/Prep/Schema/Result/Recipient.pm \
	blib/lib/Prep/Schema/Result/Recipient.pm \
	lib/Prep/Schema/Result/Role.pm \
	blib/lib/Prep/Schema/Result/Role.pm \
	lib/Prep/Schema/Result/User.pm \
	blib/lib/Prep/Schema/Result/User.pm \
	lib/Prep/Schema/Result/UserRole.pm \
	blib/lib/Prep/Schema/Result/UserRole.pm \
	lib/Prep/Schema/Result/UserSession.pm \
	blib/lib/Prep/Schema/Result/UserSession.pm \
	lib/Prep/Schema/Resultset/Recipient.pm \
	blib/lib/Prep/Schema/Resultset/Recipient.pm \
	lib/Prep/SchemaConnected.pm \
	blib/lib/Prep/SchemaConnected.pm \
	lib/Prep/Types.pm \
	blib/lib/Prep/Types.pm \
	lib/Prep/Utils.pm \
	blib/lib/Prep/Utils.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 7.1001
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --
CP_NONEMPTY = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'cp_nonempty' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = prep_api
DISTVNAME = prep_api-20190114


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(BOOTSTRAP) $(INST_DYNAMIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	lib/Data/Verifier.pm \
	lib/Prep/Schema/Result/ChatbotSession.pm \
	lib/Prep/Schema/Result/Recipient.pm \
	lib/Prep/Schema/Result/Role.pm \
	lib/Prep/Schema/Result/User.pm \
	lib/Prep/Schema/Result/UserRole.pm \
	lib/Prep/Schema/Result/UserSession.pm
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) -u \
	  lib/Data/Verifier.pm $(INST_MAN3DIR)/Data::Verifier.$(MAN3EXT) \
	  lib/Prep/Schema/Result/ChatbotSession.pm $(INST_MAN3DIR)/Prep::Schema::Result::ChatbotSession.$(MAN3EXT) \
	  lib/Prep/Schema/Result/Recipient.pm $(INST_MAN3DIR)/Prep::Schema::Result::Recipient.$(MAN3EXT) \
	  lib/Prep/Schema/Result/Role.pm $(INST_MAN3DIR)/Prep::Schema::Result::Role.$(MAN3EXT) \
	  lib/Prep/Schema/Result/User.pm $(INST_MAN3DIR)/Prep::Schema::Result::User.$(MAN3EXT) \
	  lib/Prep/Schema/Result/UserRole.pm $(INST_MAN3DIR)/Prep::Schema::Result::UserRole.$(MAN3EXT) \
	  lib/Prep/Schema/Result/UserSession.pm $(INST_MAN3DIR)/Prep::Schema::Result::UserSession.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = bin/schema.dump.sh

pure_all :: $(INST_SCRIPT)/schema.dump.sh
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/schema.dump.sh 

$(INST_SCRIPT)/schema.dump.sh : bin/schema.dump.sh $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/schema.dump.sh
	$(CP) bin/schema.dump.sh $(INST_SCRIPT)/schema.dump.sh
	$(FIXIN) $(INST_SCRIPT)/schema.dump.sh
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/schema.dump.sh



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  $(BASEEXT).bso $(BASEEXT).def \
	  $(BASEEXT).exp $(BASEEXT).x \
	  $(BOOTSTRAP) $(INST_ARCHAUTODIR)/extralibs.all \
	  $(INST_ARCHAUTODIR)/extralibs.ld $(MAKE_APERL_FILE) \
	  *$(LIB_EXT) *$(OBJ_EXT) \
	  *perl.core MYMETA.json \
	  MYMETA.yml blibdirs.ts \
	  core core.*perl.*.? \
	  core.[0-9] core.[0-9][0-9] \
	  core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] \
	  core.[0-9][0-9][0-9][0-9][0-9] lib$(BASEEXT).def \
	  mon.out perl \
	  perl$(EXE_EXT) perl.exe \
	  perlmain.c pm_to_blib \
	  pm_to_blib.ts so_locations \
	  tmon.out 
	- $(RM_RF) \
	  blib 
	  $(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile : create_distdir
	$(NOECHO) $(ECHO) Generating META.yml
	$(NOECHO) $(ECHO) '---' > META_new.yml
	$(NOECHO) $(ECHO) 'abstract: '\''PREP API'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'author:' >> META_new.yml
	$(NOECHO) $(ECHO) '  - '\''Lucas Ansei <lucastakushi@hotmail.com.com>'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'build_requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  ExtUtils::MakeMaker: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  File::Spec: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  IO::Handle: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  IPC::Open3: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Mojo::Util: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Test::Mojo: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Test::More: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  lib: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'configure_requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  ExtUtils::MakeMaker: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'dynamic_config: 1' >> META_new.yml
	$(NOECHO) $(ECHO) 'generated_by: '\''ExtUtils::MakeMaker version 7.1001, CPAN::Meta::Converter version 2.150005'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'license: open_source' >> META_new.yml
	$(NOECHO) $(ECHO) 'meta-spec:' >> META_new.yml
	$(NOECHO) $(ECHO) '  url: http://module-build.sourceforge.net/META-spec-v1.4.html' >> META_new.yml
	$(NOECHO) $(ECHO) '  version: '\''1.4'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'name: prep_api' >> META_new.yml
	$(NOECHO) $(ECHO) 'no_index:' >> META_new.yml
	$(NOECHO) $(ECHO) '  directory:' >> META_new.yml
	$(NOECHO) $(ECHO) '    - t' >> META_new.yml
	$(NOECHO) $(ECHO) '    - inc' >> META_new.yml
	$(NOECHO) $(ECHO) 'requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  App::Sqitch: '\''0.9996'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Config::General: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Crypt::PRNG: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBD::Pg: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBIx::Class::Core: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBIx::Class::InflateColumn::Serializer: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBIx::Class::PassphraseColumn: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBIx::Class::ResultSet: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBIx::Class::Schema: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  DBIx::Class::TimeStamp: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  DDP: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Diver: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Manager: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Printer: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Section::Simple: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Validate::URI: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Verifier::Field: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Verifier::Filters: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Verifier::Results: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Visitor: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Data::Visitor::Callback: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Exporter: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  FindBin: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Mojo::Base: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Moose: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Moose::Role: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Moose::Util::TypeConstraints: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  MooseX::MarkAsMethods: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  MooseX::NonMoose: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  MooseX::Types: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  Scalar::Util: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  common::sense: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  namespace::autoclean: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  perl: '\''5.014002'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  strict: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  utf8: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  vars: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) '  warnings: '\''0'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'version: '\''20190114'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'x_serialization_backend: '\''CPAN::Meta::YAML version 0.018'\''' >> META_new.yml
	-$(NOECHO) $(MV) META_new.yml $(DISTVNAME)/META.yml
	$(NOECHO) $(ECHO) Generating META.json
	$(NOECHO) $(ECHO) '{' > META_new.json
	$(NOECHO) $(ECHO) '   "abstract" : "PREP API",' >> META_new.json
	$(NOECHO) $(ECHO) '   "author" : [' >> META_new.json
	$(NOECHO) $(ECHO) '      "Lucas Ansei <lucastakushi@hotmail.com.com>"' >> META_new.json
	$(NOECHO) $(ECHO) '   ],' >> META_new.json
	$(NOECHO) $(ECHO) '   "dynamic_config" : 1,' >> META_new.json
	$(NOECHO) $(ECHO) '   "generated_by" : "ExtUtils::MakeMaker version 7.1001, CPAN::Meta::Converter version 2.150005",' >> META_new.json
	$(NOECHO) $(ECHO) '   "license" : [' >> META_new.json
	$(NOECHO) $(ECHO) '      "open_source"' >> META_new.json
	$(NOECHO) $(ECHO) '   ],' >> META_new.json
	$(NOECHO) $(ECHO) '   "meta-spec" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "url" : "http://search.cpan.org/perldoc?CPAN::Meta::Spec",' >> META_new.json
	$(NOECHO) $(ECHO) '      "version" : "2"' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "name" : "prep_api",' >> META_new.json
	$(NOECHO) $(ECHO) '   "no_index" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "directory" : [' >> META_new.json
	$(NOECHO) $(ECHO) '         "t",' >> META_new.json
	$(NOECHO) $(ECHO) '         "inc"' >> META_new.json
	$(NOECHO) $(ECHO) '      ]' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "prereqs" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "build" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "ExtUtils::MakeMaker" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "File::Spec" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "IO::Handle" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "IPC::Open3" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Mojo::Util" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Test::Mojo" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Test::More" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "lib" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "configure" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "ExtUtils::MakeMaker" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "runtime" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "App::Sqitch" : "0.9996",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Config::General" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Crypt::PRNG" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBD::Pg" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBIx::Class::Core" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBIx::Class::InflateColumn::Serializer" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBIx::Class::PassphraseColumn" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBIx::Class::ResultSet" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBIx::Class::Schema" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DBIx::Class::TimeStamp" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "DDP" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Diver" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Manager" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Printer" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Section::Simple" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Validate::URI" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Verifier::Field" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Verifier::Filters" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Verifier::Results" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Visitor" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Data::Visitor::Callback" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Exporter" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "FindBin" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Mojo::Base" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Moose" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Moose::Role" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Moose::Util::TypeConstraints" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "MooseX::MarkAsMethods" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "MooseX::NonMoose" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "MooseX::Types" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "Scalar::Util" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "common::sense" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "namespace::autoclean" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "perl" : "5.014002",' >> META_new.json
	$(NOECHO) $(ECHO) '            "strict" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "utf8" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "vars" : "0",' >> META_new.json
	$(NOECHO) $(ECHO) '            "warnings" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      }' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "release_status" : "stable",' >> META_new.json
	$(NOECHO) $(ECHO) '   "version" : "20190114",' >> META_new.json
	$(NOECHO) $(ECHO) '   "x_serialization_backend" : "JSON::PP version 2.27300"' >> META_new.json
	$(NOECHO) $(ECHO) '}' >> META_new.json
	-$(NOECHO) $(MV) META_new.json $(DISTVNAME)/META.json


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)_uu'

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)'
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).zip'
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).shar'
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir distmeta 
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:
ci :
	$(ABSPERLRUN) -MExtUtils::Manifest=maniread -e '@all = sort keys %{ maniread() };' \
	  -e 'print(qq{Executing $(CI) @all\n});' \
	  -e 'system(qq{$(CI) @all}) == 0 or die $$!;' \
	  -e 'print(qq{Executing $(RCS_LABEL) ...\n});' \
	  -e 'system(qq{$(RCS_LABEL) @all}) == 0 or die $$!;' --


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.yml to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.json to MANIFEST: $$$${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : distmeta
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLPRIVLIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLARCHLIB)" \
		"$(INST_BIN)" "$(DESTINSTALLBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLSCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLMAN3DIR)"
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		"$(SITEARCHEXP)/auto/$(FULLEXT)"


pure_site_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLSITELIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLSITEARCH)" \
		"$(INST_BIN)" "$(DESTINSTALLSITEBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLSITESCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLSITEMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLSITEMAN3DIR)"
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		"$(PERL_ARCHLIB)/auto/$(FULLEXT)"

pure_vendor_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_LIB)" "$(DESTINSTALLVENDORLIB)" \
		"$(INST_ARCHLIB)" "$(DESTINSTALLVENDORARCH)" \
		"$(INST_BIN)" "$(DESTINSTALLVENDORBIN)" \
		"$(INST_SCRIPT)" "$(DESTINSTALLVENDORSCRIPT)" \
		"$(INST_MAN1DIR)" "$(DESTINSTALLVENDORMAN1DIR)" \
		"$(INST_MAN3DIR)" "$(DESTINSTALLVENDORMAN3DIR)"


doc_perl_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" $(INSTALLPRIVLIB) \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" $(INSTALLSITELIB) \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"

doc_vendor_install :: all
	$(NOECHO) $(ECHO) Appending installation info to "$(DESTINSTALLARCHLIB)/perllocal.pod"
	-$(NOECHO) $(MKPATH) "$(DESTINSTALLARCHLIB)"
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" $(INSTALLVENDORLIB) \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> "$(DESTINSTALLARCHLIB)/perllocal.pod"


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist"

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist"

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist"


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = "/home/lucas/perl5/perlbrew/perls/perl-5.24.0/bin/perl"

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR="" \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t t/chatbot/*.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="$(VERSION)">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>PREP API</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Lucas Ansei &lt;lucastakushi@hotmail.com.com&gt;</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <PERLCORE VERSION="5,014002,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="App::Sqitch" VERSION="0.9996" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Config::General" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Crypt::PRNG" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBD::Pg" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Class::Core" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Class::InflateColumn::Serializer" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Class::PassphraseColumn" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Class::ResultSet" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Class::Schema" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Class::TimeStamp" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DDP::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Diver" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Manager" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Printer" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Section::Simple" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Validate::URI" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Verifier::Field" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Verifier::Filters" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Verifier::Results" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Visitor" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Data::Visitor::Callback" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Exporter::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="FindBin::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Mojo::Base" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Moose::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Moose::Role" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Moose::Util::TypeConstraints" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="MooseX::MarkAsMethods" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="MooseX::NonMoose" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="MooseX::Types" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Scalar::Util" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="common::sense" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="namespace::autoclean" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="strict::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="utf8::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="vars::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="warnings::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="x86_64-linux-5.24" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/Data/Verifier.pm blib/lib/Data/Verifier.pm \
	  lib/Mojolicious/Plugin/Detach.pm blib/lib/Mojolicious/Plugin/Detach.pm \
	  lib/Mojolicious/Plugin/SimpleAuthentication.pm blib/lib/Mojolicious/Plugin/SimpleAuthentication.pm \
	  lib/Prep.pm blib/lib/Prep.pm \
	  lib/Prep/Authentication.pm blib/lib/Prep/Authentication.pm \
	  lib/Prep/Authorization.pm blib/lib/Prep/Authorization.pm \
	  lib/Prep/Controller.pm blib/lib/Prep/Controller.pm \
	  lib/Prep/Controller/Chatbot.pm blib/lib/Prep/Controller/Chatbot.pm \
	  lib/Prep/Controller/Chatbot/Recipient.pm blib/lib/Prep/Controller/Chatbot/Recipient.pm \
	  lib/Prep/Data/Manager.pm blib/lib/Prep/Data/Manager.pm \
	  lib/Prep/Data/Visitor.pm blib/lib/Prep/Data/Visitor.pm \
	  lib/Prep/Role/Verification.pm blib/lib/Prep/Role/Verification.pm \
	  lib/Prep/Role/Verification/TransactionalActions.pm blib/lib/Prep/Role/Verification/TransactionalActions.pm \
	  lib/Prep/Role/Verification/TransactionalActions/DBIC.pm blib/lib/Prep/Role/Verification/TransactionalActions/DBIC.pm \
	  lib/Prep/Routes.pm blib/lib/Prep/Routes.pm \
	  lib/Prep/Schema.pm blib/lib/Prep/Schema.pm \
	  lib/Prep/Schema/Result/ChatbotSession.pm blib/lib/Prep/Schema/Result/ChatbotSession.pm \
	  lib/Prep/Schema/Result/Recipient.pm blib/lib/Prep/Schema/Result/Recipient.pm \
	  lib/Prep/Schema/Result/Role.pm blib/lib/Prep/Schema/Result/Role.pm \
	  lib/Prep/Schema/Result/User.pm blib/lib/Prep/Schema/Result/User.pm \
	  lib/Prep/Schema/Result/UserRole.pm blib/lib/Prep/Schema/Result/UserRole.pm \
	  lib/Prep/Schema/Result/UserSession.pm blib/lib/Prep/Schema/Result/UserSession.pm \
	  lib/Prep/Schema/Resultset/Recipient.pm blib/lib/Prep/Schema/Resultset/Recipient.pm \
	  lib/Prep/SchemaConnected.pm blib/lib/Prep/SchemaConnected.pm \
	  lib/Prep/Types.pm blib/lib/Prep/Types.pm \
	  lib/Prep/Utils.pm blib/lib/Prep/Utils.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
