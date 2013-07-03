# ChangeLog

## NEXT

  *

## v1.0.12 (2013-05-31)

  * Fix for ruby 2.0.0

## v1.0.11 (2013-03-07)

  * Supports Instance#availability\_zone in API response.
  * Renames Deployment#cancel to Deployment#timeout, though still support using #cancel.

## v1.0.10 (2013-02-20)

  * Provide a test scenario for stuck deployments

## v1.0.9 (2013-02-20)

  * Add the ability to cancel stuck deployments

## v1.0.8 (2013-02-14)

  * Loosen the multi\_json gem version requirement to allow 1.0 compatible security fixes.

## v1.0.7 (2012-10-25)

  * Send serverside\_version to the deployment API when starting a deploy.

## v1.0.6 (2012-08-20)

  *

## v1.0.5 (2012-08-14)

  *

## v1.0.4 (2012-08-14)

  * Send input\_ref to deployments in the extra config.
  * Use Connection object to take over for all api communication, simplifying the CloudClient class.
  * Interface for creating a CloudClient has changed to support new Connection class.

## v1.0.3 (2012-06-13)

  *

## v1.0.2 (2012-05-29)

  *

## v1.0.1 (2012-05-22)

  * Includes fixes for deployment test harness used by this gem and engineyard gem

## v1.0.0 (2012-05-22)

  * First attempt at a real release.
  * Provides all the functionality that is needed for engineyard gem to operate.
  * Like Torchwood, The Colbert Report, and The Cleveland Show, start CloudClient's new life as a spin-off.

