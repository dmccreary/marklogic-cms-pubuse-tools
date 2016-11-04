Tools for loading up CMS Claims Public Use Files

Includes Roxy Loaders that use mlcp options file.

Here is the script to load the small datasets in the data directory:
```
ml local mlcp -options_file mlcp-options-files/inpatient.txt
ml local mlcp -options_file mlcp-options-files/outpatient.txt
ml local mlcp -options_file mlcp-options-files/rx.txt
```

Once these run you can verify that all 600 data items have been loaded by running the following from the views menu:


```/views/metrics.xqy```