# MRI preprocesing pipeline

## Git branches

* master: for normal development of the pipelines
* deploy: for deployment of the pipelines to a Data Factory.

All commits on the deploy branch should be signed with PGP by an authorised developer.
Use

```
   git merge --no-ff
```

to merge code from master branch to deploy branch, then

```
  git commit -S -m "Signoff"
```

to add a signoff and allow deployment of the pipeline to the Data Factories.

## Signoffs

* 28/11/2016 - Ludovic Claude
