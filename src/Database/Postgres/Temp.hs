{-|
This module provides functions for creating a temporary @postgres@ instance.
By default it will create a temporary data directory and
a temporary directory for a UNIX domain socket for @postgres@ to listen on.

Here is an example using the expection safe 'with' function:

 @
 'with' $ \\db -> 'Control.Exception.bracket'
    ('PG.connectPostgreSQL' ('toConnectionString' db))
    'PG.close' $
    \\conn -> 'PG.execute_' conn "CREATE TABLE foo (id int)"
 @

To extend or override the defaults use `withConfig` (or `startConfig`).

@tmp-postgres@ ultimately calls (optionally) @initdb@, @postgres@ and
(optionally) @createdb@.

All of the command line, environment variables and configuration files
that are generated by default for the respective executables can be
extended.

In general @tmp-postgres@ is useful if you want a clean temporary
@postgres@ and do not want to worry about clashing with an existing
postgres instance (or needing to ensure @postgres@ is already running).

Here are some different use cases for @tmp-postgres@ and their respective
configurations:

* The default 'with' and 'start' functions can be used to make a sandboxed
temporary database for testing.
* By disabling @initdb@ one could run a temporary
isolated postgres on a base backup to test a migration.
* By using the 'stopPostgres' and 'withRestart' functions one can test
backup strategies.

WARNING!!
Ubuntu's PostgreSQL installation does not put @initdb@ on the @PATH@. We need to add it manually.
The necessary binaries are in the @\/usr\/lib\/postgresql\/VERSION\/bin\/@ directory, and should be added to the @PATH@

 > echo "export PATH=$PATH:/usr/lib/postgresql/VERSION/bin/" >> /home/ubuntu/.bashrc

-}

module Database.Postgres.Temp
  (
  -- * Exception safe interface
    with
  , withConfig
  , withRestart
  -- * Separate start and stop interface.
  , start
  , startConfig
  , stop
  , restart
  , stopPostgres
  -- * Main resource handle
  , DB
  -- ** 'DB' accessors
  , toConnectionString
  , toConnectionOptions
  , toDataDirectory
  , toTemporaryDirectory
  -- ** 'DB' mutators
  , makeDataDirPermanent
  , reloadConfig
  -- ** 'DB' debugging
  , prettyPrintDB
  -- * Configuration
  -- ** Defaults
  , defaultConfig
  , defaultPostgresConf
  , standardProcessConfig
  -- ** Custom Config builder helpers
  , optionsToDefaultConfig
  -- ** 'Config'
  , Config (..)
  , prettyPrintConfig
    -- *** 'Config' Lenses
  , planL
  , socketClassL
  , dataDirectoryL
  , portL
  , connectionTimeoutL
  -- ** 'Plan'
  , Plan (..)
  -- *** 'Plan' lenses
  , postgresConfigFileL
  , createDbConfigL
  , dataDirectoryStringL
  , initDbConfigL
  , loggerL
  , postgresPlanL
  -- ** 'PostgresPlan'
  , PostgresPlan (..)
  -- *** 'PostgresPlan' lenses
  , connectionOptionsL
  , postgresConfigL
  -- ** 'ProcessConfig'
  , ProcessConfig (..)
  -- *** 'ProcessConfig' Lenses
  , commandLineL
  , environmentVariablesL
  , stdErrL
  , stdInL
  , stdOutL
  -- ** 'EnvironmentVariables'
  , EnvironmentVariables (..)
  -- *** 'EnvironmentVariables' Lenses
  , inheritL
  , specificL
  -- ** 'CommandLineArgs'
  , CommandLineArgs (..)
  -- *** 'CommandLineArgs' Lenses
  , indexBasedL
  , keyBasedL
  -- ** 'DirectoryType'
  , DirectoryType (..)
  -- ** 'SocketClass'
  , SocketClass (..)
  -- ** 'Logger'
  , Logger
  -- * Internal events passed to the 'logger' .
  , Event (..)
    -- * Errors
  , StartError (..)
  ) where
import Database.Postgres.Temp.Internal
import Database.Postgres.Temp.Internal.Core
import Database.Postgres.Temp.Internal.Config
