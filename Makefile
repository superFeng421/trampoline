#
# Trampoline OS
#
# Trampoline is copyright (c) IRCCyN 2005+
# Trampoline est prot�g� par la loi sur la propri�t� intellectuelle
#
# This software is distributed under the Lesser GNU Public Licence
#
# $Date$
# $Rev$
# $Author$
# $URL$
#

#Warning, this Makefile must not be modified directly!
#Please define your configuration in the Make-rules file.
#

include Make-rules

# 
# configures all autosar dependant variables
#
ifeq ($(AUTOSAR),true)
  AUTOSAR_GOIL_FLAG = --autosar
  AUTOSAR_DEP = AUTOSAR
  CFLAGS += -I$(AUTOSAR_PATH)
	AUTOSAR_MAKE_FLAG = AUTOSAR=true
else
  AUTOSAR_GOIL_FLAG =
  AUTOSAR_DEP =
	AUTOSAR_MAKE_FLAG =
endif

ALL: $(EXE)

DOC:
	doxygen

#compile oil file into c, and then into .o
OIL_OBJ_OIL_FILE = $(addprefix $(OBJ_PATH)/,$(notdir $(OIL_GENERATED_C_FILE:.c=.o)))
CFLAGS += -I$(OS_MACHINE_PATH)  -I$(OIL_OUTPUT_PATH) -I$(OS_PATH) -I$(COM_PATH)

OIL: OBJ $(OIL_OBJ_OIL_FILE)

$(OIL_GENERATED_C_FILE): $(OIL_FILE) 
	$(GOIL_COMPILER) --target=$(ARCH) --templates=$(GOIL_TEMPLATE_PATH) $(OIL_FILE) $(AUTOSAR_GOIL_FLAG)

$(OIL_OBJ_OIL_FILE) : $(OIL_GENERATED_C_FILE) 
	$(CC) $(CFLAGS) -c $< -o $@

#make OS objects.
OS: OBJ OIL
	@cd $(OS_PATH) && make OS $(AUTOSAR_MAKE_FLAG)

#make COM objects.
COM: OBJ OIL
	@cd $(COM_PATH) && make COM

AUTOSAR: OBJ OIL
	cd $(AUTOSAR_PATH) && make AUTOSAR

#make User Application objects.
APP: OBJ OIL
	@cd $(APP_PATH) && make APP $(AUTOSAR_MAKE_FLAG)

#make object directory.
OBJ:
	@if [ ! -d $(OBJ_PATH) ]; then mkdir $(OBJ_PATH); fi; 

$(EXE): OS APP COM $(AUTOSAR_DEP)
	$(CC) $(LDFLAGS) -o $@ $(OBJ_PATH)/*.o

clean: cleanOIL
	@cd $(OS_PATH) && make clean 
	@cd $(COM_PATH) && make clean 
	@cd $(OS_MACHINE_PATH) && make clean 
	@cd $(APP_PATH) && make clean 
	@rm -rf $(OBJ_PATH) $(EXE)

cleanOIL:
	@cd $(OIL_OUTPUT_PATH) && rm -f tpl_os_generated_configuration.c tpl_os_generated_configuration.h tpl_app_objects.h
