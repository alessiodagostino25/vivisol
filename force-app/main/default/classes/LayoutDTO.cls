public class LayoutDTO {
    @AuraEnabled
    public List<LayoutSection> layoutSections {get;set;}

    public class LayoutSection {
        @AuraEnabled
        public List<LayoutColumn> layoutColumns {get;set;}
        @AuraEnabled
        public String label {get;set;}
    }

    public class LayoutColumn {
        @AuraEnabled
        public List<LayoutItem> layoutItems {get;set;}
        @AuraEnabled
        public Integer columnNumber {get;set;}
    }

    public class LayoutItem {
        @AuraEnabled
        public String field {get;set;}
        @AuraEnabled
        public Behavior behavior {get;set;}
        @AuraEnabled
        public Boolean emptySpace {get;set;}
        @AuraEnabled
        public Boolean readOnly {get;set;}
        @AuraEnabled
        public Boolean required {get;set;}
    }

    public class Behavior {
        @AuraEnabled
        public String behaviorValue {get; set;}
    }

    public LayoutDTO(Metadata.Layout layoutMetadata) {
        if(layoutMetadata.layoutSections != null) {
            List<LayoutSection> sections = new List<LayoutSection>();

            for(Metadata.LayoutSection layoutSection : layoutMetadata.layoutSections) {
                LayoutSection section = new LayoutSection();
                section.label = layoutSection.label;

                if(layoutSection.layoutColumns != null) {
                    List<LayoutColumn> columns = new List<LayoutColumn>();

                    for(Metadata.LayoutColumn layoutColumn : layoutSection.layoutColumns) {
                        LayoutColumn column = new LayoutColumn();
                        column.columnNumber = (layoutSection.layoutColumns).indexOf(layoutColumn);

                        if(layoutColumn.layoutItems != null) {
                            List<LayoutItem> items = new List<LayoutItem>();

                            for(Metadata.LayoutItem layoutItem : layoutColumn.layoutItems) {
                                LayoutItem item = new LayoutItem();
                                item.field = layoutItem.field;
                                item.emptySpace = layoutItem.emptySpace;
                                item.readOnly = false;
                                item.required = false;

                                if(layoutItem.behavior != null) {
                                    Behavior behavior = new Behavior();

                                    if(layoutItem.behavior == Metadata.UiBehavior.EDIT) {
                                        behavior.behaviorValue = 'EDIT';
                                    }
                                    else if(layoutItem.behavior == Metadata.UiBehavior.READONLY) {
                                        behavior.behaviorValue = 'READONLY';
                                        item.readOnly = true;
                                    }
                                    else if(layoutItem.behavior == Metadata.UiBehavior.REQUIRED) {
                                        behavior.behaviorValue = 'REQUIRED';
                                        item.required = true;
                                    }

                                    item.behavior = behavior;
                                }

                                items.add(item);
                            }
                            column.layoutItems = items;
                        }

                        columns.add(column);
                    }

                    section.layoutColumns = columns;
                }

                sections.add(section);
            }

            this.layoutSections = sections;
        }
    }
}