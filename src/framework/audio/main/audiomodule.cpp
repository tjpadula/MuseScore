/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore Limited and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
#include "audiomodule.h"

#include "ui/iuiactionsregister.h"
#include "global/modularity/ioc.h"

#include "audio/common/audiosanitizer.h"
#include "audio/common/audiothreadsecurer.h"
#ifdef Q_OS_WASM
#include "audio/common/rpc/platform/web/webrpcchannel.h"
#include "platform/web/websoundfontcontroller.h"
#else
#include "audio/common/rpc/platform/general/generalrpcchannel.h"
#include "platform/general/generalsoundfontcontroller.h"
#endif

#include "internal/audioconfiguration.h"
#include "internal/audioactionscontroller.h"
#include "internal/audiouiactions.h"
#include "internal/startaudiocontroller.h"
#include "internal/playback.h"
#include "internal/audiodrivercontroller.h"

#include "diagnostics/idiagnosticspathsregister.h"

#include "log.h"

using namespace muse;
using namespace muse::modularity;
using namespace muse::audio;

#if 0
// IOS_CONFIG_BUG
#ifdef MUSE_MODULE_AUDIO_JACK
#include "audio/driver/platform/jack/jackaudiodriver.h"
#endif

#if defined(Q_OS_LINUX) || defined(Q_OS_FREEBSD)
#include <QtEnvironmentVariables>
#include "audio/driver/platform/lin/alsaaudiodriver.h"
#ifdef MUSE_PIPEWIRE_AUDIO_DRIVER
#include "audio/driver/platform/lin/pwaudiodriver.h"
#endif
#endif

#ifdef Q_OS_WIN
//#include "audio/driver/platform/win/winmmdriver.h"
//#include "audio/driver/platform/win/wincoreaudiodriver.h"
#include "audio/driver/platform/win/wasapiaudiodriver.h"
#endif

#ifdef Q_OS_MACOS
#include "audio/driver/platform/osx/osxaudiodriver.h"
#endif

#ifdef Q_OS_IOS
#include "audio/driver/platform/ios/iosaudiodriver.h"
#endif

#ifdef Q_OS_WASM
#include "audio/driver/platform/web/webaudiodriver.h"
#endif

static void audio_init_qrc()
{
    Q_INIT_RESOURCE(audio);
}

#endif
AudioModule::AudioModule()
{
    AudioSanitizer::setupMainThread();
}

std::string AudioModule::moduleName() const
{
    return "audio";
}

void AudioModule::registerExports()
{
    m_configuration = std::make_shared<AudioConfiguration>(iocContext());
    m_actionsController = std::make_shared<AudioActionsController>(iocContext());
    m_mainPlayback = std::make_shared<Playback>(iocContext());
    m_audioDriverController = std::make_shared<AudioDriverController>(iocContext());

#ifdef Q_OS_WASM
    m_rpcChannel = std::make_shared<rpc::WebRpcChannel>();
    m_soundFontController = std::make_shared<WebSoundFontController>();
#else
    m_rpcChannel = std::make_shared<rpc::GeneralRpcChannel>();
    m_soundFontController = std::make_shared<GeneralSoundFontController>(iocContext());
#endif

#if 0
// IOS_CONFIG_BUG
#if defined(MUSE_MODULE_AUDIO_JACK)
    m_audioDriver = std::shared_ptr<IAudioDriver>(new JackAudioDriver());
#else

#if defined(Q_OS_LINUX) || defined(Q_OS_FREEBSD)
    m_audioDriver = makeLinuxAudioDriver();
#endif

#ifdef Q_OS_WIN
    //m_audioDriver = std::shared_ptr<IAudioDriver>(new WinmmDriver());
    //m_audioDriver = std::shared_ptr<IAudioDriver>(new CoreAudioDriver());
    m_audioDriver = std::shared_ptr<IAudioDriver>(new WasapiAudioDriver());
#endif

#ifdef Q_OS_MACOS
    m_audioDriver = std::shared_ptr<IAudioDriver>(new OSXAudioDriver());
#endif

#ifdef Q_OS_IOS
    m_audioDriver = std::shared_ptr<IAudioDriver>(new IOSAudioDriver());
#endif

#ifdef Q_OS_WASM
    m_audioDriver = std::shared_ptr<IAudioDriver>(new WebAudioDriver());
#endif

#endif // MUSE_MODULE_AUDIO_JACK
#else
    m_startAudioController = std::make_shared<StartAudioController>(m_rpcChannel, iocContext());
#endif
    ioc()->registerExport<IAudioConfiguration>(moduleName(), m_configuration);
    ioc()->registerExport<IStartAudioController>(moduleName(), m_startAudioController);
    ioc()->registerExport<IAudioThreadSecurer>(moduleName(), std::make_shared<AudioThreadSecurer>());
    ioc()->registerExport<rpc::IRpcChannel>(moduleName(), m_rpcChannel);
    ioc()->registerExport<IAudioDriverController>(moduleName(), m_audioDriverController);
    ioc()->registerExport<ISoundFontController>(moduleName(), m_soundFontController);
    ioc()->registerExport<IPlayback>(moduleName(), m_mainPlayback);

    m_startAudioController->registerExports();
}

void AudioModule::resolveImports()
{
    auto ar = ioc()->resolve<ui::IUiActionsRegister>(moduleName());
    if (ar) {
        ar->reg(std::make_shared<AudioUiActions>(m_actionsController));
    }
}

void AudioModule::onInit(const IApplication::RunMode& mode)
{
    m_configuration->init();

    if (mode == IApplication::RunMode::AudioPluginRegistration) {
        return;
    }

    m_actionsController->init();

    // rpc
    m_rpcChannel->setupOnMain();
#ifndef Q_OS_WASM
    m_rpcTicker.start(1, [this]() {
        m_rpcChannel->process();
    }, Ticker::Mode::Repeat);
#endif

    m_mainPlayback->init();

    m_startAudioController->init();

#ifndef Q_OS_WASM
    m_startAudioController->startAudioProcessing(mode);
#endif

    //! --- Diagnostics ---
    auto pr = ioc()->resolve<muse::diagnostics::IDiagnosticsPathsRegister>(moduleName());
    if (pr) {
        std::vector<io::path_t> paths = m_configuration->soundFontDirectories();
        for (const io::path_t& p : paths) {
            pr->reg("soundfonts", p);
        }
    }

    m_audioInited = true;
}

void AudioModule::onDeinit()
{
    if (!m_audioInited) {
        return;
    }

    m_mainPlayback->deinit();
    m_rpcTicker.stop();

    m_startAudioController->stopAudioProcessing();
}
